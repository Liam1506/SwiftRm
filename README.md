# SwiftRm

An unofficial Swift client for the reMarkable Cloud API.

> [!WARNING]  
> **Disclaimer:** This project is not affiliated with, endorsed by, or supported by reMarkable AS. "reMarkable" is a registered trademark of reMarkable AS. Use this software at your own risk. The author is not responsible for any data loss or account issues.

---

## Project Status: Early Alpha
This project is in its **very early stages**. The API is not stable and is currently intended for development and exploration purposes only.

## Current Functionality
The following features are currently implemented and functional:
* **Authentication:** Integration with the reMarkable Cloud authentication service.
* **Cloud Navigation:** Fetching and listing the folder and file structure directly from your account.
* **Move:** Move documents and folders to a different location in the cloud.
* **Trash:** Move documents and folders to the trash.
* **Upload:** Upload PDF or ePub files to the cloud.
* **Create Folder:** Create new folders in the cloud.
* **Download:** Download the original PDF/ePub file for a document.
* **Notebook Parsing:** Download and parse reMarkable notebook pages (`.rm` files) for v3, v5, and v6 formats.
* **rmfakecloud Support:** Connect to a self-hosted [rmfakecloud](https://github.com/ddvk/rmfakecloud) instance via `RemarkableConfig.rmfakecloud(host:)`.

## Acknowledgements
This project is inspired by [rmapi](https://github.com/ddvk/rmapi) and the work done by the reMarkable community to document the cloud API.
