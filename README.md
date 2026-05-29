# Smart Home Automation App with Voice Control Access

A responsive, cross-platform Flutter application built to monitor and control smart home appliances (lights, fans, air conditioners, heaters) on a local network.

## Key Features

* **Customizable IoT Settings**: Configure individual microcontroller IP addresses (ESP32/ESP8266) inside the settings panel dynamically without changing source code.
* **Integrated Voice Assistant**: Hands-free voice assistant overlay (Siri/Bixby style) to perform navigation actions and toggle smart appliances using natural language.
* **System-Wide Quick Settings Tile**: Quick Settings Tile integration on Android to trigger voice control instantly from outside the application.
* **Responsive Layout**: Adapts dynamically between mobile screens (vertical stacked controls) and tablet screens (split view panels).
* **Crash-Resistant Interface**: Uses dynamic Layout Builders to prevent UI overflows when the software keyboard is active.

## Technical Architecture

* **Frontend**: Flutter & Dart
* **State Management**: Riverpod
* **Networking**: Direct HTTP REST communication with local microcontrollers (ESP32/ESP8266 relays)
* **Local Storage**: Persistent configurations via SharedPreferences