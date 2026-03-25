# Collateral Links Backend — Setup (60 seconds)

This powers the "+ Link" buttons in the Collateral Tracker.

## Steps

### 1. Create the Script
Go to [script.google.com](https://script.google.com) → **New Project**

### 2. Paste this code (replace everything in the editor)

```javascript
function doGet(e) {
  var store = PropertiesService.getScriptProperties();
  var data = store.getProperty('links') || '{}';
  return ContentService.createTextOutput(data)
    .setMimeType(ContentService.MimeType.JSON);
}

function doPost(e) {
  try {
    var body = JSON.parse(e.postData.contents);
    var store = PropertiesService.getScriptProperties();
    store.setProperty('links', JSON.stringify(body));
    return ContentService.createTextOutput(JSON.stringify({ok: true}))
      .setMimeType(ContentService.MimeType.JSON);
  } catch(err) {
    return ContentService.createTextOutput(JSON.stringify({error: err.message}))
      .setMimeType(ContentService.MimeType.JSON);
  }
}
```

### 3. Deploy
- Click **Deploy** → **New deployment**
- Type: **Web app**
- Execute as: **Me**
- Who has access: **Anyone**
- Click **Deploy** → **Authorize access** → Allow
- **Copy the Web App URL**

### 4. Set the URL
Paste the URL to Claude, or edit `index.html` and set the `_linksEndpoint` variable.

The URL looks like: `https://script.google.com/macros/s/AKfyc.../exec`
