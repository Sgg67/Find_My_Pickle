# Find_My_Pickle

## Our Goal
Do you love pickleball like me and have trouble finding courts near you. If so
we created the greatest app for you it is called Find My Pickle. Now you can find courts near you
based on your current location or the city name you enter.

## App Core functionality

### Find Courts Near You Based On Location
When a user presses the button they are able to see a list of courts near them. Searching courts based on location is done through the google maps places api.

<img src = "Screenshot_20251125_183733.jpg" width = "300">


<img src = "Screenshot_20251125_183749.jpg" width = "300">

### Search for Courts In Your City
This allows users to enter a City and State and search for courts near them and a list of courts are displayed. Searching courts based on City and State is done through the google maps places api.

<img src = "Screenshot_20251125_184222.jpg" width = "300">

<img src = "Screenshot_20251125_184252.jpg" width = "300">

### Court Details
This has information about a particular court this includes:
• Court rating
• Court Address
• Directions button
• Share button
• Join a Game button

<img src = "Screenshot_20251125_191231.jpg" width = "300">

#### Get Directions button
This prompts the user to use location the first time and once the user accepts. It opens directions up in Google Maps or another maps
app of choice. If the user does not enter location, then when maps opens they have to enter the location manually.

<img src = "Screenshot_20251125_191533_Maps.jpg" width = "300">

#### Share Button
This allows users to share the court details to others, via text, email, etc.

<img src = "Screenshot_20251125_191821_IntentResolver.jpg" width = "300" >

#### Join a Game Button
This allows a user to join or create a pickup game session at a particular pickleball court location. This is done using firebase database which maps users to a particular court.

<img src = "Screenshot_20251125_192148.jpg" width = "300">


### Add Courts to Favorites
On the court details page the user can click the favorite icon to add a particular court to the favorites. 

<img src = "Screenshot_20251125_192606.jpg" width  = "300">

<img src = "Screenshot_20251125_192713.jpg" width = "300">


### Profile Picture
This allows users to add a photo to their profile which is distinctive when you are registered for a game. 
You have to be signed in, in order to add a picture to your profile. If you are signed in you can add a picture to your profile and this
is handled via firebase storage. 

<img src = "Screenshot_20251125_193357_Photos & videos.jpg" width = "300">


## Login Services

### Create an account
This allows users to create an account to access some advanced features like adding a profile photo
and joining and creating pickup games. This account creation is handled via firebase authentication.

<img src = "Screenshot_20251125_184835.jpg" width = "300">

### Login 
This allows a user to login their account, this authentication is done using firebase authentication.

<img src = "Screenshot_20251125_185053.jpg" width = "300">

### Reset Password
This features sends a password reset email to the users email if the account exists. This is done through firebase authentication.
Just a note the password reset email gets sent to spam, which is because we do not currently have a domain set up for our app.

<img src = "Screenshot_20251125_185409.jpg" width  = "300">

<img src = "Screenshot_20251125_190049_Gmail.jpg" width = "300">


## Find a pickup game near you
Are you like me and have no friends and are looking for pickup games near you. With Find My Pickle you can signup for games 
at a particular court location and join other peoples games. Now you no longer have to play by your self and you can now play
the doubles games of your dreams.

<img src = "Screenshot_20251125_182011.jpg" width = "300">


## App Walkthrough
Here is a link for the app Walkthrough video
https://photos.app.goo.gl/tdLvqAYpbbNfWEc5A

## MVVM Walkthrough video
Here is a link for the MVVM Overview
https://photos.app.goo.gl/qh6nteL3nUg9GAgy8

## Firebase Services
- **Authentication** (`firebase_auth`):
  - Handles secure user sign-in via Email/Password.
  - Integration with **Google Sign-In**.
  - Anonymous/Guest login support.
- **Cloud Firestore** (`cloud_firestore`):
  - **User Management:** Stores profiles and account metadata.
  - **Game Sessions:** Real-time synchronization of active pickleball games, player lists, and court availability.
- **Storage** (`firebase_storage`):
  - Secure hosting for user-uploaded content (e.g., profile pictures).
- **Core** (`firebase_core`):
  - Manages app initialization and platform-specific configuration.

## Maps & Location APIs
- **Google Places API:**
  - Fetches detailed information about pickleball courts (names, addresses, photos, ratings).
- **Google Geocoding API:**
  - Converts user search queries (city names) into geographic coordinates (lat/lng).
- **Google Directions API:**
  - Calculates routes and navigation paths to selected courts.
- **Geolocator** (`geolocator`):
  - Accesses the device's native GPS to find courts near the user's current location

## MVVM Diagram
<img width="387" height="633" alt="image" src="https://github.com/user-attachments/assets/dc9b6edf-7946-49f8-a50a-48bc6196081b" />

[Model.pdf](https://github.com/user-attachments/files/23861785/Model.pdf)

## 📦 Dependencies

This project relies on the following packages and plugins:

### Core & State Management
| Package | Version |
| :--- | :--- |
| **Flutter SDK** | Stable |
| **Provider** | `^6.1.5+1` |
| **HTTP** | `^1.5.0` |

### Firebase & Backend
| Package | Version |
| :--- | :--- |
| **Firebase Core** | `^4.2.1` |
| **Firebase Auth** | `^6.1.2` |
| **Google Sign In** | `^6.1.5` | 
| **Cloud Firestore** | `^6.1.0` | 
| **Firebase Storage** | `^13.0.4` |

### UI & Design
| Package | Version |
| :--- | :--- |
| **Google Fonts** | `^6.1.0` |
| **Animated Text Kit**| `^4.2.2` |
| **Fluttertoast** | `^8.2.4` |
| **Custom Button Builder**| `^0.0.1` |
| **Cupertino Icons** | `^1.0.8` |

### Device & Native Features
| Package | Version | 
| :--- | :--- | 
| **Geolocator** | `^14.0.2` | 
| **Image Picker** | `^1.0.7` |
| **URL Launcher** | `^6.1.11` | 
| **Share Plus** | `^7.0.1` |
| **Permission Handler**| `^11.0.0` |

---

## Build Instructions

### Prerequisites
* **Dart SDK:** Version `>=3.9.0 <4.0.0`
* **Flutter SDK:** Latest Stable (Compatible with the Dart SDK requirement)

### 1. Setup
Clone the repository and install the dependencies:
```bash
git clone [https://github.com/your-username/find_my_pickle.git](https://github.com/your-username/find_my_pickle.git)
cd find_my_pickle
flutter pub get
```

### 2. Running the App
```bash
flutter run
```
