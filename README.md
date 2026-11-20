# Shaligram

Shaligram is an Android-first Flutter devotional video app with a calm saffron-and-cream interface, a browseable guest experience, Firebase-backed video catalog, account sign-in, and protected moderation architecture. It runs with demo catalog content before Firebase setup.

## Run the Flutter app

1. Install the Flutter SDK and Android Studio, then run `flutter doctor`.
2. From the project root run:
   ```sh
   flutter pub get
   flutter run
   ```
3. Create native platform scaffolding if this repository was cloned without it:
   ```sh
   flutter create --platforms=android,ios .
   ```
   Keep the existing `lib/` and `pubspec.yaml` when prompted. Android is the first target; iOS can be configured later.

The repository intentionally contains Flutter source and Firebase rules rather than generated Android/iOS boilerplate. The app starts in demo mode when Firebase is not configured. Demo video cards are illustrative; playback needs a real Storage download URL.

## Connect Firebase

1. Create a Firebase project and register an Android app using the application ID from your generated `android/app/build.gradle` (set your final package ID before registering).
2. Install the Firebase CLI and FlutterFire CLI, authenticate, then from the repository root run:
   ```sh
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. Enable **Authentication** providers (Email/Password and Google), **Cloud Firestore**, and **Cloud Storage** in the Firebase console.
4. Add the generated Android `google-services.json` and iOS `GoogleService-Info.plist` as directed by FlutterFire/Firebase tooling. Configure the Google sign-in SHA-1/SHA-256 fingerprints and OAuth client in Firebase; for iOS, configure the reversed client ID as required by the generated setup.
5. The app initializes Firebase from the native platform configuration (`Firebase.initializeApp()`). Do not check secrets or private service-account credentials into source control. Firebase client configuration values are not authorization; rules and Auth are the security boundary.
6. If Android Gradle requires the Google Services plugin, apply the current Firebase Android setup instructions to the generated Gradle files. Then run `flutter run` again.

## Configure Storage and security rules

The bucket is created when you enable Firebase Storage. Deploy the supplied rules from this project root:

```sh
firebase login
firebase use --add
firebase deploy --only firestore:rules,firestore:indexes,storage
```

The deployed catalog layout uses `videos/` and `thumbnails/` in Storage. Admin-only writes are enforced with the `admin: true` Firebase Authentication custom claim. Public Storage read is intended only for catalog media; never upload private files beneath these public paths. Published approval is enforced in Firestore before the app can discover video documents.

## Upload videos in Firebase Console

1. In **Storage**, upload a video to `videos/<descriptive-file-name>.mp4` and its poster image to `thumbnails/<descriptive-file-name>.jpg`.
2. Open each object's details and copy its download URL. The app streams the `videoUrl` field directly via `video_player` and displays `thumbnailUrl` as the poster.
3. In **Firestore**, create the `videos` collection and a document with a stable ID (for example `morning-darshan-001`). Add the fields in the schema below. Set `moderationStatus` to `approved` and `isPublished` to `true` only after review.
4. Create corresponding documents in the `categories` collection. The category document ID must match `categoryId` on videos. Mark it `isPublished: true`.

### Firestore schema

`videos/{videoId}`:

| Field | Type | Example |
|---|---|---|
| `title` | string | `Morning Darshan at Vrindavan` |
| `description` | string | `A peaceful start to your day.` |
| `categoryId` | string | `morning-darshan` |
| `categoryName` | string | `Morning Darshan` |
| `videoUrl` | string | Storage download URL for `videos/...` |
| `thumbnailUrl` | string | Storage download URL for `thumbnails/...` |
| `durationSeconds` | number | `420` |
| `featured` | boolean | `true` |
| `views` | number | `0` |
| `isPublished` | boolean | `true` |
| `moderationStatus` | string | `approved` |
| `publishedAt` | timestamp | Firestore Timestamp (not a string) |

`categories/{categoryId}`:

```json
{
  "name": "Krishna Bhakti",
  "icon": "🦚",
  "sortOrder": 1,
  "isPublished": true
}
```

Use these initial category IDs: `krishna-bhakti`, `radha-krishna`, `mahadev`, `shri-ram`, `hanuman`, `maa-durga`, `morning-darshan`, `aarti-bhajans`, `spiritual-stories`, `temple-darshan`. The app currently includes these category labels locally so Explore stays useful; Firestore categories are ready for managed catalog expansion. Featured content is chosen by setting `featured: true` on a published video.

Firestore may prompt for the composite index when the catalog query is first run; the matching index is included in `firestore.indexes.json`.

## Administrator access

Never store an `isAdmin` field that users can edit in their profile. A trusted server-side environment (Cloud Functions/Admin SDK, operated only by project owners) must assign the Firebase Auth custom claim `admin: true` to verified administrator UIDs. The supplied rules check that claim for video/category management and moderation. Do not put an Admin SDK service-account key in this app or repository. You can manually manage the first catalog items from Firebase Console while signed in with privileged project access.

## Future user uploads (disabled)

The UI deliberately does not expose user uploads. Storage writes under `user-submissions/` are denied (`allow write: if false`) and Firestore submissions are private/pending. Before enabling uploads, implement an authenticated submission screen and server-side validation/moderation; set a size/MIME allow-list in Storage rules; create metadata with `status: pending` and an immutable owner UID; allow only trusted admins to transition status and publish an approved copy into the public catalog paths. Never let a client set `approved`, `isPublished`, or admin claims. Test rules in the Firebase Emulator Suite before deployment.

## Notes

- Guest browsing is supported. Sign-in is optional; Google sign-in requires Firebase provider setup and Android SHA fingerprints.
- Favorites are available during the current app session and are written to the signed-in user's private Firestore subcollection when possible. A later enhancement can load that subcollection on sign-in to restore favorites across devices.
- The video player includes playback, scrubbing, volume/mute, fullscreen, favorites, and share. Set real Storage URLs in the catalog before expecting streaming.
- Dark mode follows the system setting. UI components adapt to available screen width with scrollable content and Material 3 controls.
