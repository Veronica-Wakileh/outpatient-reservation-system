# Outpatient Reservation System

A terminal-based outpatient appointment system written in Bash. It allows patients to register, book, view, and cancel appointments, and lets admins manage doctors and view their schedules. Data is stored in simple pipe-delimited text files.

---

## Course Information

- **University:** Birzeit University
- **Department:** Electrical & Computer Engineering
- **Course:** ENCS3130 – Linux Laboratory
- **Semester:** First Summer Semester, 2024/2025
- **Project:** Shell Scripting Project – Outpatient Reservation System

## Project Features

### Patient Features
- Register as a new patient with a unique auto-generated ID (e.g., `P001`).
- Search doctors by specialty (Cardiology, Orthopedics, Dermatology, Pediatrics).
- Book an appointment with input validation:
  - The chosen day must match the doctor's available days.
  - The date must follow the format `YYYY-MM-DD`.
  - The date's weekday must match the chosen day.
  - The time must be in `HH:MM` format and within the doctor's working hours.
  - Prevents booking a time slot already taken.
  - Prevents the same patient from booking two appointments at the same time.
- View upcoming and past appointments using the patient's ID.
- Cancel an existing appointment (status is updated, the record is not deleted).

### Admin Features
- Add a new doctor with auto-generated ID (e.g., `D001`).
- Update an existing doctor's:
  - Available days
  - Working hours (start and end time)
  - Specialty
- View any doctor's schedule with booked dates, times, and patient names.

---

## File Structure

```
project/
│
├── shell.sh           # Main shell script (entry point)
├── doctors.txt        # Doctors database
├── patients.txt       # Patients database
├── apointments.txt    # Appointments database (note: filename uses one "p")
└── README.md          # This file
```

> **Note:** The appointments file is named `apointments.txt` (with a single `p`). This is the exact filename used inside the script, so it must remain spelled this way for the script to work correctly.

---

## Data File Formats

All files use `|` (pipe) as the field separator.

### `doctors.txt`
```
DoctorID|Name|Specialty|AvailableDays|StartTime|EndTime
```
Example:
```
D001|Dr. Shahd Sbaih|Cardiology|Sun,Mon,Wed|08:00|14:00
```

### `patients.txt`
```
PatientID|Name|Phone
```
Example:
```
P001|Ali Ahmed|01087654321
```

### `apointments.txt`
```
AppointmentID|PatientID|DoctorID|Date|Time|Status
```
Example:
```
A001|P001|D001|2025-08-12|09:30|Confirmed
```

Possible statuses: `Confirmed`, `Pending`, `Cancelled`.

---

## How to Run the Project

1. Open a Linux terminal in the project folder.
2. Make sure the three data files (`doctors.txt`, `patients.txt`, `apointments.txt`) exist in the same folder as `shell.sh`.
3. Give the script execution permission:

   ```bash
   chmod +x shell.sh
   ```

4. Run the script:

   ```bash
   ./shell.sh
   ```

5. Choose your role at the welcome menu:
   - `1` for **Patient**
   - `2` for **Admin**

---

## Example Usage Flow

### Patient Flow
1. Run the script → choose `1) patient`.
2. If new, choose `y` to register; enter your full name and phone number.
3. The system prints your generated Patient ID (e.g., `P009`).
4. From the patient menu, choose:
   - `1) Book an appointment` → pick a specialty → pick a doctor by ID → pick a working day → enter a matching date → enter a time within working hours.
   - `2) View My Appointments` → enter your Patient ID to see upcoming and past bookings.
   - `3) Cancel Appointment` → enter your Patient ID, then the Appointment ID to cancel.

### Admin Flow
1. Run the script → choose `2) Admin`.
2. From the admin menu, choose:
   - `1) Add a doctor` → enter name, specialty, working days, start and end time.
   - `2) Update Doctor Schedule` → enter the Doctor ID, then choose what to modify (availability / working hours / specialty).
   - `3) View Doctor Schedule` → enter the Doctor ID to view all booked appointments grouped by date, with patient names.
   - `4) Exit` → end the session.

---

## Input Validation

The script performs several validation checks to avoid invalid data:

- **Phone numbers:** must contain only digits and be at least 9 digits long.
- **Date format:** must follow `YYYY-MM-DD` (regex check), and must correspond to a real day matching the chosen weekday.
- **Time format:** must follow `HH:MM` (00–23 : 00–59).
- **Working hours:** booking time must fall within the doctor's start and end time.
- **Specialty selection:** restricted to a fixed menu of available specialties.
- **Doctor ID / Patient ID:** must exist in the corresponding file before proceeding.
- **Database existence:** before each menu action, the script checks that the required `.txt` files exist.
- **Duplicate prevention:** registration warns if the patient name already exists.

---

## Known Notes / Limitations

- The appointments file name is `apointments.txt` (one `p`). Renaming it will break the script unless all references inside `shell.sh` are also updated.
- Specialty search is restricted to the four hard-coded options in the booking menu (Cardiology, Orthopedics, Dermatology, Pediatrics). Doctors of other specialties added by the admin will not appear in the patient search menu unless the menu is extended.
- Patient name duplicate detection is done by name match only; two patients with the same name will be treated as the same person at registration.
- IDs are generated sequentially based on the current line count of each file, so manually editing the files may cause ID conflicts.
- The system is designed to run in a single Linux terminal session and does not support concurrent users.

---

## Future Improvements

- Add a login system with passwords for both roles.
- Allow the patient menu to loop so the user can perform multiple actions without restarting.
- Make the specialty list dynamic by reading unique values from `doctors.txt`.
- Add an admin option to view all patients and to back up the database files.
- Add a search-by-date or search-by-doctor feature for admins.
- Improve duplicate detection using phone numbers or full IDs instead of names.

---

## Conclusion

This project applies basic Linux shell scripting concepts — file handling, control flow, input validation, regex, and menu-driven design — to build a small but realistic outpatient reservation system. It demonstrates how text files can be used as a lightweight database and how Bash can be used to organize a multi-role application with separate flows for patients and admins.
