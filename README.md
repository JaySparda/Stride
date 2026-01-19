# stride

**Stride** is a high-performance, cross-platform productivity tool built with Flutter. It features a sophisticated **Offline-First Architecture**, allowing users to manage their life seamlessly regardless of their internet connection.

## 🌟 Key Features

- **Offline-First Synchronization:** Uses `sqflite` for local persistence and `Firebase` for cloud backup. The app detects connectivity changes in real-time and syncs data automatically.
- **Dynamic Task Management:** Full CRUD (Create, Read, Update, Delete) functionality for tasks.
- **Momentum Tracking:** A smart progress bar that visualizes daily completion rates to keep users motivated.
- **Categorical Filtering:** Organize tasks into Work, Study, or Personal categories using interactive Material 3 chips.
- **Privacy Centric:** No mandatory account required for local use.

## 🏗️ Technical Architecture

Stride is built using a **Clean Architecture** pattern to ensure the code is scalable and easy to test.

- **Frontend:** Flutter (Material 3)
- **State Management:** Provider
- **Local Database:** SQLite (sqflite)
- **Cloud Backend:** Google Firebase (Firestore)
- **Network Monitoring:** Connectivity Plus

## Getting Started

### Prerequisites

- Flutter SDK (Latest Version)
- Android Studio / VS Code
- A Firebase Project

### Installation
