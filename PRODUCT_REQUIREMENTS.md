# Product Requirement Document: Smart Class Check-in & Learning Reflection App

## 1. Problem Statement

Universities face challenges in accurately tracking student attendance and gauging their engagement and understanding of course material. Traditional methods like manual roll calls are time-consuming, prone to errors, and fail to capture valuable insights into the student learning experience. There is a need for an automated system that not only verifies a student's physical presence in the classroom but also encourages active participation and reflection on the learning process.

## 2. Target User

The primary target users for this application are university students enrolled in various courses. A secondary user (not covered in this phase) would be the instructor or university administration who would view the collected data.

## 3. Feature List

The application will include the following features:

-   **F1: Pre-Class Check-in:**
    -   **F1.1:** Initiate check-in process with a single button press.
    -   **F1.2:** Capture and store the student's GPS location.
    -   **F1.3:** Capture and store the current timestamp.
    -   **F1.4:** Scan a unique QR code for the class session.
    -   **F1.5:** A pre-class form for students to input:
        -   The topic covered in the previous class.
        -   The topic they expect to learn today.
        -   Their mood on a 5-point scale (1: Very Negative to 5: Very Positive).

-   **F2: Post-Class Completion:**
    -   **F2.1:** Initiate the class completion process.
    -   **F2.2:** Scan the class QR code again to confirm completion.
    -   **F2.3:** Capture and store the student's GPS location and timestamp upon finishing.
    -   **F2.4:** A post-class form for students to input:
        -   A short summary of what they learned today.
        -   Feedback for the instructor or about the class.

## 4. User Flow

1.  **Before Class:**
    -   The student opens the application.
    -   The student taps the "Check-in" button on the main screen.
    -   The system automatically records the GPS location and timestamp.
    -   The camera interface opens for the student to scan the class QR code.
    -   Upon a successful scan, the student is presented with the "Pre-Class Reflection" form.
    -   The student fills out the form and submits it. The data is saved to the backend.

2.  **After Class:**
    -   The student opens the application.
    -   The student taps the "Finish Class" button.
    -   The camera interface opens to scan the QR code again.
    -   The system records the GPS location and timestamp.
    -   Upon a successful scan, the student is presented with the "Class Completion" form.
    -   The student fills out the feedback form and submits it. The data is saved to the backend.

## 5. Data Fields

The following data will be collected and stored for each check-in/completion record.

| Field Name                  | Data Type       | Description                                          | Example                               |
| --------------------------- | --------------- | ---------------------------------------------------- | ------------------------------------- |
| `studentId`                 | String          | Unique identifier for the student.                   | "user123"                             |
| `classId`                   | String          | Unique identifier for the class session (from QR).   | "CS101-2026-03-13"                    |
| `checkinTimestamp`          | DateTime        | Timestamp of the initial check-in.                   | "2026-03-13T09:00:00Z"                |
| `checkinGps`                | Geopoint        | GPS coordinates at check-in.                         | `(13.736717, 100.523186)`             |
| `previousTopic`             | String          | Student's reflection on the last class.              | "Introduction to Flutter Widgets"     |
| `expectedTopic`             | String          | Student's expectation for the current class.         | "State Management in Flutter"         |
| `mood`                      | Integer (1-5)   | Student's mood before class.                         | 4                                     |
| `completionTimestamp`       | DateTime        | Timestamp of the class completion.                   | "2026-03-13T12:00:00Z"                |
| `completionGps`             | Geopoint        | GPS coordinates at completion.                       | `(13.736717, 100.523186)`             |
| `learnedToday`              | String          | Student's summary of what they learned.              | "Learned about `setState` and `Provider`." |
| `feedback`                  | String          | Student's feedback on the class or instructor.       | "The pace was a bit fast."            |

## 6. Tech Stack

-   **Mobile Application Framework:** Flutter
-   **Backend Service:** Firebase
    -   **Database:** Firestore (for storing check-in and reflection data)
    -   **Authentication:** Firebase Authentication (for user management, if needed)
-   **Required Flutter Packages:**
    -   `geolocator`: To get the device's GPS location.
    -   `qr_code_scanner`: To scan QR codes from the camera.
    -   `cloud_firestore`: To interact with the Firebase Firestore database.
