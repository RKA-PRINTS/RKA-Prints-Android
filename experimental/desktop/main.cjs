'use strict';
const { app, BrowserWindow, Menu, shell, session, dialog } = require('electron');
const path = require('node:path');
const { HOME, isInternalUrl, isExternalUrl } = require('./navigation-policy.cjs');

let mainWindow;
const isMac = process.platform === 'darwin';

async function openExternal(url) {
  if (!isExternalUrl(url)) return;
  // Never pass website-supplied file:, javascript:, intent: or custom schemes to the OS.
  try { await shell.openExternal(url); }
  catch { if (mainWindow) dialog.showErrorBox('Unable to open link', 'Please open this link in your regular browser.'); }
}

function installMenu() {
  const navigate = fn => { if (mainWindow && !mainWindow.isDestroyed()) fn(mainWindow.webContents); };
  const menu = [
    ...(isMac ? [{ label: app.name, submenu: [{ role: 'about' }, { type: 'separator' }, { role: 'hide' }, { role: 'hideOthers' }, { role: 'unhide' }, { type: 'separator' }, { role: 'quit' }] }] : []),
    { label: 'Navigate', submenu: [
      { label: 'Back', accelerator: 'Alt+Left', click: () => navigate(w => { if (w.navigationHistory.canGoBack()) w.navigationHistory.goBack(); }) },
      { label: 'Forward', accelerator: 'Alt+Right', click: () => navigate(w => { if (w.navigationHistory.canGoForward()) w.navigationHistory.goForward(); }) },
      { label: 'Reload', accelerator: 'CmdOrCtrl+R', click: () => navigate(w => { if (isInternalUrl(w.getURL())) w.reload(); else w.loadURL(HOME); }) },
      { label: 'Home', click: () => navigate(w => w.loadURL(HOME)) },
      { type: 'separator' },
      { label: 'Open website in browser', click: () => openExternal(HOME) },
      ...(!isMac ? [{ type: 'separator' }, { role: 'quit' }] : [])
    ] },
    { role: 'editMenu' },
    { label: 'View', submenu: [{ role: 'resetZoom' }, { role: 'zoomIn' }, { role: 'zoomOut' }, { type: 'separator' }, { role: 'togglefullscreen' }] },
    { role: 'windowMenu' }
  ];
  Menu.setApplicationMenu(Menu.buildFromTemplate(menu));
}

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200, height: 850, minWidth: 360, minHeight: 480,
    title: 'RKA Prints Experimental', backgroundColor: '#f6f9f7',
    icon: path.join(__dirname, 'build-resources/icon.png'),
    webPreferences: { nodeIntegration: false, contextIsolation: true, sandbox: true, webSecurity: true, allowRunningInsecureContent: false, webviewTag: false, devTools: false, spellcheck: true }
  });
  const contents = mainWindow.webContents;
  const leaveApp = (event, url) => {
    if (isInternalUrl(url)) return;
    event.preventDefault();
    void openExternal(url);
  };
  contents.on('will-navigate', leaveApp);
  contents.on('will-redirect', (event, url) => { if (!isInternalUrl(url)) event.preventDefault(); });
  contents.setWindowOpenHandler(({ url }) => {
    if (isInternalUrl(url)) void contents.loadURL(url);
    else void openExternal(url);
    return { action: 'deny' };
  });
  contents.on('page-title-updated', event => event.preventDefault());
  contents.on('will-attach-webview', event => event.preventDefault());
  contents.on('did-fail-load', (_event, code, _description, url, mainFrame) => {
    if (mainFrame && code !== -3 && isInternalUrl(url)) void contents.loadFile(path.join(__dirname, 'offline.html'));
  });
  mainWindow.on('closed', () => { mainWindow = null; });
  void mainWindow.loadURL(HOME);
}

if (!app.requestSingleInstanceLock()) app.quit();
else {
  app.on('second-instance', () => {
    if (mainWindow) { if (mainWindow.isMinimized()) mainWindow.restore(); mainWindow.focus(); }
  });
  app.whenReady().then(() => {
    app.setAboutPanelOptions({ applicationName: 'RKA Prints Experimental', applicationVersion: '0.1.0', comments: 'The live RKA Prints website in a desktop app. Internet required.' });
    // The wrapper does not silently grant camera, microphone, notifications or geolocation.
    session.defaultSession.setPermissionRequestHandler((_webContents, _permission, callback) => callback(false));
    session.defaultSession.setPermissionCheckHandler(() => false);
    // Electron's normal download dialog lets the user choose the location. Never auto-run downloaded files.
    session.defaultSession.on('will-download', (_event, item) => item.setSaveDialogOptions({ title: 'Save RKA Prints download' }));
    installMenu();
    createWindow();
    app.on('activate', () => { if (BrowserWindow.getAllWindows().length === 0) createWindow(); });
  });
  app.on('window-all-closed', () => { if (!isMac) app.quit(); });
}
