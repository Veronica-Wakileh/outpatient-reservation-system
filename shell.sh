#Shahd Sbaih 1220060
#Veronica Wakileh 1220245

###################################################
#Patient Functions
#Register
register() {
  echo "-> For registeration:"
  echo "-> Enter your full name:"
  read name
  #check if the patient already have an account
  if grep -i "$name" patients.txt > /dev/null; then
    echo "-> Patient already exists"
    Patient
  fi
  #as long as he is not registered take his phone number until given a vaild phone number
  while true ; do
    echo "-> Enter your phone number: " 
    read phone
    #only numbers should enter
    echo "$phone" | grep -Eq "^[0-9]{9,}$"
    if [ $? -eq 0 ]; then
      break
    else
      echo "-> Invalid phone number"
    fi
  done

  if [ -s patients.txt ]; then
    Line_Count=$(cat patients.txt | wc -l)
  else
    Line_Count=0
  fi
  new_id=$((Line_Count + 1))
  patient_id=$(printf "P%03d" $new_id)

  echo -e "\n${patient_id}|${name}|${phone}" >> patients.txt
  echo "-> Registration successful :) --> Your Patient ID is: $patient_id"
}
########################################################################
#Booking
book_appointment() {
#Patients search doctors by specialty
echo "-> What specialty are you looking for?"
echo -e "1)Cardiology\n2) Orthopedics\n3) Dermatology\n4) Pediatrics "
read choice
case $choice in
    1) specialty="Cardiology" 
      ;;

    2) specialty="Orthopedics" 
      ;;

    3) specialty="Dermatology" 
      ;;

    4) specialty="Pediatrics" 
      ;;

    *) echo "-> Invalid choice."
      return 
      ;;
esac

GettingDoctors=$(grep -i "|$specialty|" doctors.txt)


if [ -z "$GettingDoctors" ]; then
    echo "-> Sorry there's no $specialty doctors here :( )"
    return
fi

echo "-> Here are our $specialty doctors:"

#to separate doctor's info
while read -r l; do
  id=$(echo "$l" | cut -d'|' -f1)
  name=$(echo "$l" | cut -d'|' -f2)
  spec=$(echo "$l" | cut -d'|' -f3)
  days=$(echo "$l" | cut -d'|' -f4)
  start=$(echo "$l" | cut -d'|' -f5)
  end=$(echo "$l" | cut -d'|' -f6)

  echo "ID: $id | Name: $name | Specialty: $spec | Available Days: $days | Time: $start to $end "
done <<< "$GettingDoctors"

echo "-> Enter the Doctor ID you want to book with:"
read doctor

doctor_line=$(echo "$GettingDoctors" | grep -i "^$doctor|")
if [ -z "$doctor_line" ]; then
  echo "-> Not a $specialty doctor "
  echo "-> Re-enter the Doctors ID from these doctors that spicialize in $specialty"
  echo "$GettingDoctors"
  echo "-> Choose one of the $specialty doctors: "
  read doctor
fi
Dr_name=$(echo "$doctor_line" | cut -d'|' -f2)
available_days=$(echo "$doctor_line" | cut -d'|' -f4)
available_days=$(echo "$available_days" | tr 'A-Z' 'a-z' )


start=$(echo "$doctor_line" | cut -d'|' -f5)
end=$(echo "$doctor_line" | cut -d'|' -f6)

echo "-> $Dr_name is available on: $available_days"
echo "-> On which day would you like to book?"
read day
day=$(echo "$day" | tr 'A-Z' 'a-z' )


#chosing an available day 
#in this loop we make sure that the user chooses a day from available days 
#and if not we give him the option of re choosing an available day or exiting
#the way to get out of this loop is to match available_days and the entered day
while ! echo "$available_days" | grep -qw "$day"; do
  echo "-> This doctor does not work on $day."
  echo "-> Would you like to choose another day from these options?(y/n)"
  read YN
  if [ "$YN" != 'y'  ]; then
    return
  else
    echo "$available_days"
    read day
  fi
done

  echo "Enter your Patient ID:"
  read patient_id

####################################
  #we know that the user chose a working day for sure now
    #  هلا لازم نتأكد انو التارخ الي دخلو اليوزر هو بيجي بنفس اليوم الي اختارو لازم اعمل اشي يفحص الموضوع
####################################
  # Ask for the date and ensure it matches the selected weekday
while true; do
    echo "-> Enter the date you want in this format (YYYY-MM-DD):"
    read ansr
    if ! echo "$ansr" | grep -Eq '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
      echo "-> Invalid format please Use YYYY-MM-DD format"
    fi

# date -d "$date"--->  بتطلعلي اليوم والتاريخ  تبعون الوقت الي اليوزر دخلو
# and the +%a gives me only the (day) part of the output   
#and the 2>/dev/null part is for if the user entierd an invalid date like month 13 to hide the huge error we direct it to null

    entered_day=$(date -d "$ansr" '+%a')

  
    if [[ "$entered_day" != "$day" ]]; then
      echo "-> The date you entered is not a $day, it's a $entered_day"
      echo "-> Please try again with a correct date"
      continue
    fi

    break  
done
####################################
#and if we managed to choose a date that matches the days that the doctor works on
  #we need now to make the user choose a good time if available then good , if not offer available time slots and if chosen then good if not offer different days
  #if chosen re-check the date and time matter if not ask if wanting to exit
####################################
while true; do
  echo " Enter preferred time between $start and $end :"
  read time
  #################
  #same as we did in date but here we have from hour 00 ti 23 and from minute 00 to 59
if ! echo "$time" | grep -Eq '^([0-1][0-9]|2[0-3]):[0-5][0-9]$'; then
    echo "-> Invalid time please enter HH:MM in the correct format"
    continue
fi

  ################
  # Check if time is within working hours
  if [[ "$time" < "$start" || "$time" > "$end" ]]; then
    echo "-> The doctor does not work during this time. Try another."
    continue
  fi

  # Check if that slot is already booked
  if grep "$doctor|$date|$time|Confirmed" apointments.txt ; then
    echo "-> This time slot is already booked."
    echo -e "1) Try another time on the same day\n2) Try a different day\n3) Try a different Doctor\n4) Exit"
    read answer

    case $answer in
      1)
        continue
        ;;
      2)
        # go back to ask for a new date
        echo "-> Let's choose a different day..."
        # use break to exit inner time loop and go back to day/date loop
        break
        ;;
      3)
        # restart the whole function
        echo "-> Let's choose a different doctor..."
        book_appointment
        return
        ;;
      4)
        echo "--------->Exiting appointment booking<----------"
        return
        ;;
      *)
        echo "Invalid"
        continue
        ;;
    esac
  fi
  
  # Check if the patient already has an appointment at the same time
  if grep -q "|$patient_id|.*|$date|$time|Confirmed" apointments.txt ; then
    echo "-> You already have an appointment at this time!"
    echo -e "1) Try another time\n2) Exit"
    read answer
    case $answer in
      1)
        continue
        ;;
      2)
        echo "-> Exiting booking."
        return
        ;;
      *)
        echo "-> Invalid option."
        continue
        ;;
    esac
  fi

  break
done

  if [ -s apointments.txt ]; then
    Line_Count=$(cat apointments.txt | wc -l)
  else
    Line_Count=0
  fi
  new_id=$((Line_Count + 1))
  apt_id=$(printf "A%03d" $new_id)

  # Save appointment to appointments.txt
  echo -e "\n${apt_id}|${patient_id}|${doctor}|${date}|${time}|Confirmed" >> apointments.txt

  # Confirmation message
  echo "Appointment booked successfully!"
  echo "ID: $apt_id | Doctor: $doctor | Date: $date | Time: $time"
}
########################################################################
#View appointments
view_appointments() {
  echo "-> to view appointments enter your Patient ID :"
  read idApoint
  idApoint=$(echo "$idApoint" | tr 'a-z' 'A-Z' )

  # Check if patient exists
  if ! grep -i "^$idApoint|" patients.txt; then
      echo "-> Patient ID $idApoint not found. Please register first."
      return
  fi

   today=$(date +%Y%m%d)

  echo "-> Upcoming appointments:"
  while read line; do
    [[ -z "$line" ]] && continue

    id=$(echo "$line" | cut -d'|' -f1)
    pid=$(echo "$line" | cut -d'|' -f2)
    doc=$(echo "$line" | cut -d'|' -f3)
    date=$(echo "$line" | cut -d'|' -f4)
    time=$(echo "$line" | cut -d'|' -f5)
    status=$(echo "$line" | cut -d'|' -f6)

    # Convert date to YYYYMMDD
    clean_date=$(echo "$date" | tr -d '-')

    if [[ "$pid" == "$idApoint" && "$clean_date" -ge "$today" ]]; then
      echo "ID: $id | Doctor: $doc | Date: $date | Time: $time | Status: $status"
    fi
  done < apointments.txt

  echo
  echo "-> Past appointments:"
  while read line; do
   
    id=$(echo "$line" | cut -d'|' -f1)
    pid=$(echo "$line" | cut -d'|' -f2)
    doc=$(echo "$line" | cut -d'|' -f3)
    date=$(echo "$line" | cut -d'|' -f4)
    time=$(echo "$line" | cut -d'|' -f5)
    status=$(echo "$line" | cut -d'|' -f6)

    clean_date=$(echo "$date" | tr -d '-')

    if [[ "$pid" == "$idApoint" && "$clean_date" -lt "$today" ]]; then
      echo "ID: $id | Doctor: $doc | Date: $date | Time: $time | Status: $status"
    fi
  done < apointments.txt
}
########################################################################
#Cancel Appointment
cancel_appointment() { 
  echo "-> Canceling appointment..."
  echo -n "-> Enter your Patient ID: "
  read id
  id=$(echo "$id" | tr 'A-Z' 'a-z' )
  echo "-> Your appointments:"

  while read -r line; do

    aptID=$(echo "$line" | cut -d'|' -f1)
    pid=$(echo "$line" | cut -d'|' -f2)

    if [[ "$pid" == "$id" ]]; then
      echo "$line"
    fi
  done < apointments.txt

  echo -n "-> Please enter the Appointment ID you want to cancel: "
  read aptNum

  if grep -q "^$aptNum|" apointments.txt; then

    mv "$tmpfile" apointments.txt
    while read -r line; do
      curID=$(echo "$line" | cut -d'|' -f1)
      status=$(echo "$line" | cut -d'|' -f6)

      if [[ "$curID" == "$aptNum" && "$status" == "Confirmed" ]]; then
        newLine=$(echo "$line" | sed 's/Confirmed$//')
        echo "$newLine" >> "$tmpfile"
      elseCancelled
        echo "$line" >> "$tmpfile"
      fi
    done < apointments.txt

    mv "$tmpfile" apointments.txt
    echo "-> Appointment $aptNum has been cancelled successfully."
  else
    echo "-> Appointment ID not found."
  fi
}
########################################################################
#                             Patient 
########################################################################
Patient() {
  echo "-> Hii <3 , Are you new here(y/n)?"
  read ans

  if [ "$ans" != 'y'  ]; then
    echo "-> Welcome Back :)"
    while true;
    do 
    echo "-> Enter your ID to confirm:"
    read patient

    if grep -i "^$patient|" patients.txt  > /dev/null ; then
        echo "-> Patient ID confirmed ^_^"
        break
    else
      echo "-> Patient ID not found. Please register first."
    fi
    done

  else
    if [ -e patients.txt ] ;then
      register
    else
      echo "error accessing the database "
      exit
    fi
  fi
  echo -e "-> What do you want to do today?\n1) Book an appointment\n2) View My Appointments\n3) Cancel Appointment"
  read ans1
  if [ -e doctors.txt ] && [ -e apointments.txt ] && [ -e patients.txt ]; then
    case "$ans1" in
        1) 
          book_appointment
          ;;
        2) 
          view_appointments 
          ;;
        3) 
          cancel_appointment 
          ;;
        *) 
          echo "-> Invalid choice." 
          ;;
    esac
  else
    echo "error accessing the database "
    exit
  fi

}
########################################################################
#Admin Functions
#Add doctor
Add_Doctor(){
  echo "Enter Doctor's Name:"
  read name
  echo "Enter Doctor's Specialty:"
  read specialty
  echo "Enter Doctor's Working Days:"
  read days
  sleep 1

echo "Enter Doctor's Working Hours:"
    while true; 
    do
        echo "Enter Start Time:"
        read ST
        if ! echo "$ST" | grep -Eq '([0-9])|(1[0-9])|(2[0-3])|([0-9]:[0-5][0-9])| ([0-1][0-9]|2[0-3]):[0-5][0-9]$'; then
          echo "Invaild format"
        else
          if [ "$ST" == *:* ];then
            hours=$( "$ST" | cut-d':' -f1 )
            minutes=$( "$ST" | cut-d':'-f2)
          else
            hours="$ST"
            minutes="00"
          fi
          S_T=$(printf "%02d:%02d" "$hours" "$minutes")
          break
        fi
    done

    while true; 
    do
        echo "Enter End Time:"
        read ET
        if ! echo "$ET" | grep -Eq '([0-9])|(1[0-9])|(2[0-3])|([0-9]:[0-5][0-9])| ([0-1][0-9]|2[0-3]):[0-5][0-9]$'; then
          echo "Invaild format"
        else
          if [ "$ET" == *:* ];then
            hours=$( "$ET" | cut-d':' -f1 )
            minutes=$( "$ET" | cut-d':'-f2)
          else
            hours="$ET"
            minutes="00"
          fi
          E_T=$(printf "%02d:%02d" "$hours" "$minutes")
          break
        fi
    done
  if [ -s doctors.txt ] # we need this to know after which ID we are inserting the new doctor
  then
      Line_Count=$( cat doctors.txt | wc -l )
  else
      Line_Count=0
  fi
  new_id=$((Line_Count + 1))
  doctors_id=$(printf "D%03d" $new_id)
  echo -e "\n${doctors_id}|${name}|${specialty}|${days}|${S_T}|${E_T}" >> doctors.txt
  echo "Doctor "$name" was added successfully"
}
########################################################################
#Update Doctor Schedule
Update_Doctor_Schedule(){
cat doctors.txt
while true;
do
    echo "Enter Doctor's ID"
    read ID
    ID=$(echo "$ID" | tr 'a-z' 'A-Z')
    if grep -i "^$ID|" doctors.txt  > /dev/null ; then
        echo "Doctor's ID confirmed ^_^"
        break
    else
        echo "Doctor's ID not found, Please Re-Enter The ID."
    fi
done

echo "Choose do you want to do?"
echo "1-Modify Doctor's Availability"
echo "2-Modify Doctor's Working Hours"
echo "3-Modify Doctor's Specialty"
read Admin_Answer

# old_Line="D001|Dr. Shahd Sbaih|Cardiology|mon,tue,fri|08:00|14:00"
old_Line=$(grep "^$ID|" doctors.txt)
echo "$old_Line"

case "$Admin_Answer" in
    1) 
       echo "Enter New Available Dates:"
       read Dates
       pre_updated=$(echo "$old_Line" | cut -d'|' -f1-3)
       echo "$pre_updated"
       post_updated=$(echo "$old_Line" | cut -d'|' -f5-)
       echo "$post_updated"
       new_line="$pre_updated|$Dates|$post_updated"
       echo "$new_line"
       echo "Available Dates Updated !"
      ;;
    2) 
      while true; 
      do
          echo "Enter New Start Time:"
          read NEW_ST
          if ! echo "$NEW_ST" | grep -Eq '([0-9])|(1[0-9])|(2[0-3])|([0-9]:[0-5][0-9])| ([0-1][0-9]|2[0-3]):[0-5][0-9]'; then
            echo "Invaild format"
          else
            if [ "$NEW_ST" == *:* ];then
              hours=$( "$NEW_ST" | cut-d':' -f1 )
              minutes=$( "$NEW_ST" | cut-d':'-f2)
            else
              hours="$NEW_ST"
              minutes="00"
            fi
            S_T=$(printf "%02d:%02d" "$hours" "$minutes")
            break
          fi
      done
      
      while true; 
      do
          echo "Enter New End Time:"
          read NEW_ET
          if ! echo "$NEW_ET" | grep -Eq '([0-9])|(1[0-9])|(2[0-3])|([0-9]:[0-5][0-9])| ([0-1][0-9]|2[0-3]):[0-5][0-9]$'; then
            echo "Invaild format"
          else
            if [ "$NEW_ET" == *:* ];then
              hours=$( "$NEW_ET" | cut-d':' -f1 )
              minutes=$( "$NEW_ET" | cut-d':'-f2)
            else
              hours="$NEW_ET"
              minutes="00"
            fi
            E_T=$(printf "%02d:%02d" "$hours" "$minutes")
            break
          fi
      done

      pre_updated=$(echo "$old_Line" | cut -d'|' -f1-4)
      echo "$pre_updated"
      new_line="$pre_updated|$S_T|$E_T"
      echo "$new_line"
      echo "Working Hours Updated !"
      ;;
    3) 
      echo "Enter Updated Speciality:"
      read specialty
      pre_updated=$(echo "$old_Line" | cut -d'|' -f1-2)
      post_updated=$(echo "$old_Line" | cut -d'|' -f4-)
      new_line="$pre_updated|$specialty|$post_updated"
      echo "$new_line"
      echo "Specialty Updated !"
      ;;
    *) 
      echo "-> Invalid choice." 
      ;;
esac

sed -i "s/^$old_Line/$new_line/" doctors.txt

}
########################################################################
#View DoctorSchedule
View_DoctorSchedule() {
    cat doctors.txt

    while true; do
        echo -e "\nEnter Doctor's ID:"
        read DID
        DID=$(echo "$DID" | tr 'a-z' 'A-Z')
        if grep -i "^$DID|" doctors.txt > /dev/null ; then
            echo "Doctor's ID confirmed ^_^"
            break
        else
            echo "Doctor's ID not found, Please Re-Enter The ID."
        fi
    done
    echo "$DID"
    doctor_name=$(grep "^$DID|" doctors.txt | cut -d'|' -f2)
    echo "Schedule for $doctor_name"

    # Check if there are any appointments for this doctor
    if ! grep "^.*|.*|$DID|" apointments.txt > /dev/null; then
        echo "No Appointments Found for $doctor_name"
        return
    fi

    dates=$(grep "^.*|.*|$DID|" apointments.txt | cut -d'|' -f4 | sort -u)

    for date in $dates; do
        echo "$date:"
        Times=$(grep "^.*|.*|$DID|$date|" apointments.txt | cut -d'|' -f5 | sort -u)
        for time in $Times; do
            PatientID=$(grep "^.*|.*|$DID|$date|$time" apointments.txt | cut -d'|' -f2)
            PatientName=$(grep "^$PatientID|" patients.txt | cut -d'|' -f2)
            echo "Time: $time Name: $PatientName"
        done
    done
}

########################################################################
#                             Admin 
########################################################################
Admin() {

while true ; 
do
    echo -e "->How can i help?\n1)Add a doctor \n2) Update Doctor Schedule\n3) View Doctor Schedul\n4)Exit"
      read ans2
  case "$ans2" in
      1) 
        if [ -e doctors.txt ];then      
          Add_Doctor
        else
          echo "error accessing the database "
          exit
        fi
        
        ;;
      2) 
        if [ -e doctors.txt ];then      
          Update_Doctor_Schedule
        else
            echo "error accessing the database "
            exit
        fi
        ;;
      3) 
        if [ -e doctors.txt ] && [ -e apointments.txt ] && [ -e patients.txt ]; then
          View_DoctorSchedule
        else
            echo "error accessing the database "
            exit
        fi
        ;;
      4) 
        echo "Goodbye"
        break
        ;;
      *) 
        echo "-> Invalid choice." 
        ;;
  esac
done
}

##########################################################################
# Main loop
echo "-> Hey there ! , Welcome to our program"
while true; do
  echo -e "Are you a patient or a Admin? Choose:\n1) patient\n2) Admin"
  echo -n "-> "
  read answer

  case "$answer" in
    1)
      Patient
      break
      ;;
    2)
      Admin
      break
      ;;
    *)
      echo "bye bye "
      echo "Invalid choice. Please enter 1 or 2."
      ;;
  esac
done 