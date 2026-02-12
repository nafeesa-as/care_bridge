💙 CareBridge: Autism Support & Growth Tracking

CareBridge is a comprehensive mobile solution built with Flutter and Firebase, designed to empower parents and caregivers of children with autism. The app provides tools for routine management, developmental tracking, and community support, ensuring a structured and supportive environment for child development.

🌟 Key Features

📅 Daily Schedule & Routine Management
Structured Tasks: Allows parents to create and manage daily routines to provide the predictability essential for children with autism.

Task Provider: Utilizes the Provider package for efficient state management of daily activities.

📈 Growth & Development Monitor
Biometric Tracking: Dedicated modules to track Height, Weight, and Head Circumference.

Data Visualization: Integrated growth charts to monitor developmental milestones over time.

Firebase Integration: Real-time data synchronization ensuring records are always up-to-date and accessible.

🎮 Cognitive & Sensory Games
Developmental Play: Includes cognitive, language, and sensory-focused games tailored for neurodiverse learning needs.

Interactive UI: engaging and accessible game interfaces built with custom Flutter widgets.

🤝 Community Forum & Resources
Peer Support: A discussion board and events module for parents to connect and share experiences.

Resource Library: A centralized hub for educational stories and developmental resources.

🏗️ Technical Architecture

The project follows a Modular Clean Architecture, separating concerns to ensure scalability and maintainability.

📁 Project Roadmap

lib/models/: Defines the data structures for growth metrics, tasks, and forum posts.

lib/pages/: Organized by feature (e.g., GrowthMonitor, DailySchedule, CommunityForum) to keep the UI layer clean.

lib/provider/: Centralized state management using the Provider pattern (e.g., TaskProvider).

lib/components/: Reusable UI widgets to maintain design consistency.

lib/audio/ & lib/images/: Specialized assets for sensory-friendly interactions.

🛠️ Tech Stack

Frontend: Flutter (Dart)

Backend: Firebase (Authentication, Firestore, Cloud Functions)

State Management: Provider

Localization: intl for region-specific date and data formatting.
