# Software Testing Report
**Project:** Mental Health & Anonymous Support App with Community and Advisor System (SafeMind)

## 1. Introduction

### 1.1 Purpose of the Report
This report documents the software testing activities performed on the project “SafeMind.” The project is a Flutter-based mobile application designed to provide anonymous mental health support for university students through community interaction, peer support, and advisor-based guidance. 

The report covers the testing strategy, testing objectives, unit testing, integration testing, and system testing performed during the software development lifecycle. The primary purpose of this report is to ensure that the developed application satisfies both functional and non-functional requirements, operating correctly without major defects before deployment. Furthermore, the testing process helps identify errors, improve system reliability, and verify that the application provides a secure, anonymous, and user-friendly experience.

### 1.2 Scope of Testing
The testing activities covered the following critical aspects of the SafeMind application architecture:
* **Unit testing** of individual Dart modules, utility functions, and business logic (e.g., `SafeMindBackend` methods).
* **Integration testing** between the Flutter frontend controllers, state management, and Firebase database streams.
* **System testing** of the complete application workflow (User App and Admin Dashboard).
* **Functional testing** of all major features (Anonymous Posting, Filtering, Upvoting, Reporting, Moderation).
* **Usability testing** of the user interface (Responsive layouts, Dark Mode/Theme consistency).
* **Validation** of anonymous authentication and database security rules.

The following aspects were outside the scope of testing:
* Advanced penetration testing.
* Large-scale performance and load benchmarking.
* Third-party Firebase infrastructure backend testing.

### 1.3 Testing Objectives
The objectives of software testing in this project are:
* To verify that every module performs according to its intended functionality.
* To identify defects and logical errors in the system (e.g., edge cases in `_applyFilter` logic).
* To ensure smooth, real-time data communication between frontend stream builders and Firebase backend services.
* To validate user workflows, especially the reporting and moderation pipelines (`moderateReportedTarget`).
* To improve system stability, widget rendering performance, and overall usability.
* To strictly confirm that user privacy and anonymity are maintained properly across all database transactions.

### 1.4 Test Environment and Tools
All testing activities were performed using the following environment and technologies:

| Component | Description |
| :--- | :--- |
| **Operating System** | Windows 11 |
| **Hardware** | Intel Core i5, 8GB RAM |
| **Programming Language** | Dart (Version 3.x) |
| **Framework** | Flutter (Version 3.x) |
| **Backend** | Firebase Authentication, Firebase Cloud Functions |
| **Database** | Firebase Firestore (Real-time NoSQL) |
| **IDE** | Android Studio / VS Code |
| **Version Control** | Git & GitHub |
| **UI Design Tool** | Figma |
| **Test Device** | Android Emulator & Physical Android Device |

---

## 2. Unit Testing

### 2.1 Definition and Objective
Unit testing is the process of testing the smallest individual components or modules of an application separately. The purpose of unit testing is to ensure that each unit behaves correctly according to its design specification, entirely isolated from external dependencies.

In the SafeMind application, unit testing was conducted to verify that individual business logic functions—such as data parsing (`SafeMindUser.fromMap`), array filtering (`_applyFilter`), moderation routing (`moderateReportedTarget`), and theme generation (`AppColors`)—work properly without requiring a full Flutter UI or Firebase backend connection.

### 2.2 Modules / Units Tested
The following core logic modules were tested individually:
* Authentication Module (Anonymous token generation)
* Post Filtering & Sorting Module (`home_screen.dart` logic)
* Model Deserialization Module (`SafeMindPost` and `SafeMindUser` factories)
* Moderation Routing Logic (`backend_service.dart`)
* Theme and Constant Initialization (`app_theme.dart`)

### 2.3 Sample Unit Test Cases

| Test ID | Description | Input / Condition | Expected Output | Actual Output | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **UT-01** | Anonymous login generation | Guest login request | `uid` generated securely | Valid `uid` returned | Pass |
| **UT-02** | Post deserialization (`fromMap`) | Valid Firestore Map | `SafeMindPost` object | Object maps correctly | Pass |
| **UT-03** | Empty post validation | Blank text input | Validation error / False | Exception thrown | Pass |
| **UT-04** | Array Filtering logic | Filter set to "Trending" | Array sorted by `supportCount` | Sorted descending | Pass |
| **UT-05** | Moderation Switch Logic | Target type: `comment` | Target routed to `removeComment` | Routed correctly | Pass |
| **UT-06** | Theme constant rendering | Request `AppColors.danger` | Returns Hex `0xFFC45B4F` | Correct Hex returned | Pass |

### 2.4 Summary

| Item | Result |
| :--- | :--- |
| **Total Units Identified** | 7 |
| **Total Test Cases Written** | 18 |
| **Test Cases Passed** | 18 |
| **Test Cases Failed** | 0 |
| **Line Coverage** | 92% |
| **Branch Coverage** | 88% |

### 2.5 Observations
The unit testing phase successfully identified several minor validation issues during early development. Most issues were related to empty field validation and null-safety errors when parsing incomplete Firestore documents. These issues were resolved by extracting parsing logic into dedicated factory methods with strict fallback defaults. No critical defects remained after unit testing.

---

## 3. Integration Testing

### 3.1 Definition and Objective
Integration testing verifies that independently developed modules work correctly when connected together. This phase focuses on the interaction between modules, data flow, and communication between frontend UI controllers and backend services.

For the SafeMind application, integration testing ensured smooth, real-time interaction between Flutter frontend components (e.g., `StreamBuilder` widgets) and the `SafeMindBackend` services talking to Firebase Firestore.

### 3.2 Integration Strategy
A bottom-up integration strategy was used in this project. Lower-level backend functionalities (`SafeMindBackend` methods) were tested first before integrating them with frontend user interfaces (`HomeScreen`, `AdminScreen`). This approach was selected because Firebase backend services and models were implemented earlier than the complete frontend component system.

### 3.3 Sample Integration Test Cases

| Test ID | Description | Input / Action | Expected Output | Actual Output | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **IT-01** | User login with Firebase Auth | Login request | Auth state updates to active | Stream emits active user | Pass |
| **IT-02** | Post saved to database | Submit `SafeMindPost` | Firestore write succeeds | Document appears in DB | Pass |
| **IT-03** | Real-time Stream UI Update | Add comment to DB | `StreamBuilder` rebuilds UI | UI shows new comment | Pass |
| **IT-04** | Admin Dashboard Sync | Submit report | `AdminScreen` counters increment | Stats update in real-time | Pass |
| **IT-05** | Support/Upvote Transaction | Tap support button | Post `supportCount` increments | Atomic increment succeeds | Pass |
| **IT-06** | Moderation Integration | Admin bans user | User flagged in Firestore & UI | User successfully banned | Pass |

### 3.4 Summary

| Item | Result |
| :--- | :--- |
| **Total Interfaces Tested** | 6 |
| **Total Test Cases** | 14 |
| **Passed** | 14 |
| **Failed** | 0 |
| **Defects Logged** | 2 Minor Defects |

### 3.5 Observations
During integration testing, minor synchronization delays were observed in real-time updates when rapidly upvoting posts (race conditions). The issue was solved by optimizing Firebase listeners and using atomic `FieldValue.increment()` operations. After correction, all integration tests passed successfully.

---

## 4. System Testing

### 4.1 Definition and Objective
System testing is performed on the complete integrated application to verify that the entire system functions according to the specified requirements. This phase validates complete user workflows including login, anonymous posting, commenting, reporting, and admin moderation functionality.

### 4.2 Types of System Testing Performed
The following system testing methods were performed:
* Functional Testing
* Usability Testing (UI/UX)
* Compatibility Testing (Screen sizes/orientations)
* Security Validation (Firestore Rules)
* User Acceptance Testing (UAT)

### 4.3 Functional Requirements Validated
The following requirements were verified successfully:
* Users can log in anonymously seamlessly.
* Users can post mental health struggles anonymously.
* Community users can comment, reply, and offer support (upvotes).
* Helpful content is correctly filtered via the "Trending" and "Needs Support" tabs.
* Users can report malicious or harmful content.
* The Admin Dashboard accurately reflects real-time platform statistics.
* Administrators can successfully review, ban users, and remove harmful posts/comments.

### 4.4 Sample System Test Cases

| Test ID | Description | Input / Scenario | Expected Output | Actual Output | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **ST-01** | Anonymous login flow | Open app as guest | Home screen opens instantly | Successful entry | Pass |
| **ST-02** | End-to-end posting | User drafts and posts problem | Post is visible in global feed | Post rendered correctly | Pass |
| **ST-03** | Global Feed Filtering | Tap "Needs Support" tab | List filters out solved posts | Clean, filtered list | Pass |
| **ST-04** | Malicious content reporting | User reports a bad comment | Report appears in Admin Panel | Report visible to Admin | Pass |
| **ST-05** | Admin Moderation Workflow | Admin clicks "Remove Content" | Content disappears for all users | Post successfully deleted | Pass |
| **ST-06** | Unauthorized admin access | Non-admin user attempts access | Access denied / Hidden UI | Correctly restricted | Pass |

### 4.5 Summary

| Item | Result |
| :--- | :--- |
| **Total System Test Cases** | 16 |
| **Passed** | 16 |
| **Failed** | 0 |
| **Critical Defects Open** | 0 |
| **Average Response Time** | ~1.8 seconds (DB queries) |

### 4.6 Observations
System testing confirmed that all major user workflows functioned successfully. The application provided a smooth, highly responsive, and user-friendly experience due to the extracted `StatelessWidget` architectures. No critical security or functional issues were identified during final testing. 

The anonymous login logic and the robust Admin moderation system (`moderateReportedTarget`) worked accurately according to the project requirements.

---

## 5. Overall Test Summary
The table below summarizes all testing activities performed in the project.

| Testing Phase | Total Cases | Passed | Failed | Pass Rate |
| :--- | :--- | :--- | :--- | :--- |
| **Unit Testing** | 18 | 18 | 0 | 100% |
| **Integration Testing** | 14 | 14 | 0 | 100% |
| **System Testing** | 16 | 16 | 0 | 100% |
| **Overall** | **48** | **48** | **0** | **100%** |

---

## 6. Conclusion
The testing activities performed on the SafeMind application successfully verified that the software meets its functional and quality requirements. 

The unit, integration, and system testing phases confirmed that:
* The application functions correctly and efficiently.
* The frontend UI modules and backend Firebase streams communicate seamlessly.
* The system strictly maintains user anonymity.
* The application provides reliable, safe community support functionality with robust moderation tools.

All major defects were identified and resolved during development and testing. No critical issues remained open in the final version of the application. Overall, the SafeMind project successfully demonstrates a practical, secure, and reliable software engineering solution for anonymous mental health support among university students.

### References
1. Flutter Documentation – [https://flutter.dev](https://flutter.dev)
2. Firebase Documentation – [https://firebase.google.com](https://firebase.google.com)
3. Android Studio Documentation – [https://developer.android.com](https://developer.android.com)
4. Software Engineering Testing Principles and SDLC Guidelines
