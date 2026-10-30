package app.rkaprints.wrapper;

import android.app.*;
import android.content.*;
import android.net.Uri;
import android.os.*;
import android.graphics.Color;
import android.view.*;
import android.webkit.*;
import android.widget.*;

public class MainActivity extends Activity {
    private WebView web;
    private LinearLayout error;
    private ProgressBar progress;
    private ValueCallback<Uri[]> upload;
    private static final String HOME = "https://rkaprints.web.app/";

    private boolean internal(Uri uri) {
        String host = uri.getHost();
        return "https".equals(uri.getScheme()) && ("rkaprints.web.app".equals(host) || "rka-prints-invoice-maker.firebaseapp.com".equals(host) || "rka-prints-invoice-maker.web.app".equals(host));
    }
    private void external(Uri uri) {
        try { startActivity(new Intent(Intent.ACTION_VIEW, uri).addCategory(Intent.CATEGORY_BROWSABLE)); }
        catch (ActivityNotFoundException ex) { Toast.makeText(this, "No app is available to open this link.", Toast.LENGTH_SHORT).show(); }
    }
    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        int surface = getColor(R.color.app_surface);
        boolean dark = (getResources().getConfiguration().uiMode & android.content.res.Configuration.UI_MODE_NIGHT_MASK) == android.content.res.Configuration.UI_MODE_NIGHT_YES;
        getWindow().setStatusBarColor(surface);
        getWindow().setNavigationBarColor(surface);
        int systemFlags = dark ? 0 : View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR;
        if (Build.VERSION.SDK_INT >= 26 && !dark) systemFlags |= View.SYSTEM_UI_FLAG_LIGHT_NAVIGATION_BAR;
        getWindow().getDecorView().setSystemUiVisibility(systemFlags);
        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(surface);
        root.setOnApplyWindowInsetsListener((v, insets) -> {
            v.setPadding(insets.getSystemWindowInsetLeft(), insets.getSystemWindowInsetTop(), insets.getSystemWindowInsetRight(), insets.getSystemWindowInsetBottom());
            return insets.consumeSystemWindowInsets();
        });
        web = new WebView(this);
        root.addView(web, new FrameLayout.LayoutParams(-1,-1));
        WebSettings settings = web.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(false);
        settings.setAllowContentAccess(true);
        settings.setMixedContentMode(WebSettings.MIXED_CONTENT_NEVER_ALLOW);
        settings.setSupportZoom(true);
        settings.setBuiltInZoomControls(true);
        settings.setDisplayZoomControls(false);
        if (Build.VERSION.SDK_INT >= 33) settings.setAlgorithmicDarkeningAllowed(true);
        CookieManager.getInstance().setAcceptCookie(true);
        CookieManager.getInstance().setAcceptThirdPartyCookies(web, true);
        progress = new ProgressBar(this, null, android.R.attr.progressBarStyleHorizontal);
        root.addView(progress, new FrameLayout.LayoutParams(-1, 6, Gravity.TOP));
        error = new LinearLayout(this);
        error.setOrientation(LinearLayout.VERTICAL);
        error.setGravity(Gravity.CENTER);
        error.setPadding(32,32,32,32);
        error.setBackgroundColor(surface);
        TextView message = new TextView(this);
        message.setText("RKA Prints\n\nUnable to load the website.\nCheck your internet connection and try again.");
        message.setTextColor(getColor(R.color.app_ink));
        message.setTextSize(19);
        message.setGravity(Gravity.CENTER);
        error.addView(message);
        Button retry = new Button(this);
        retry.setText("Try again");
        retry.setOnClickListener(v -> { error.setVisibility(View.GONE); web.loadUrl(HOME); });
        error.addView(retry);
        root.addView(error, new FrameLayout.LayoutParams(-1,-1));
        error.setVisibility(View.GONE);
        setContentView(root);
        web.setWebViewClient(new WebViewClient() {
            @Override public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                if (!request.isForMainFrame()) return false;
                if (internal(request.getUrl())) return false;
                external(request.getUrl()); return true;
            }
            @Override public boolean shouldOverrideUrlLoading(WebView view, String url) {
                Uri uri = Uri.parse(url);
                if (internal(uri)) return false;
                external(uri); return true;
            }
            @Override public void onReceivedError(WebView view, WebResourceRequest req, WebResourceError err) {
                if(req.isForMainFrame()) error.setVisibility(View.VISIBLE);
            }
            @Override public void onPageFinished(WebView view, String url) { CookieManager.getInstance().flush(); }
        });
        web.setWebChromeClient(new WebChromeClient() {
            @Override public void onProgressChanged(WebView view, int value) {
                progress.setProgress(value); progress.setVisibility(value < 100 ? View.VISIBLE : View.GONE);
            }
            @Override public boolean onShowFileChooser(WebView view, ValueCallback<Uri[]> callback, FileChooserParams params) {
                if (upload != null) upload.onReceiveValue(null);
                upload = callback;
                try { startActivityForResult(params.createIntent(), 10); }
                catch (ActivityNotFoundException ex) { upload.onReceiveValue(null); upload = null; }
                return true;
            }
        });
        web.setDownloadListener((url, agent, disposition, mime, length) -> {
            Uri uri = Uri.parse(url);
            if (!"https".equals(uri.getScheme())) {
                Toast.makeText(this,"For this download, open the website in your browser.", Toast.LENGTH_LONG).show(); return;
            }
            try {
                android.app.DownloadManager.Request request = new android.app.DownloadManager.Request(uri);
                request.addRequestHeader("Cookie", CookieManager.getInstance().getCookie(url) == null ? "" : CookieManager.getInstance().getCookie(url));
                request.addRequestHeader("User-Agent", agent);
                request.setMimeType(mime);
                request.setNotificationVisibility(android.app.DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);
                request.setDestinationInExternalFilesDir(this, Environment.DIRECTORY_DOWNLOADS, URLUtil.guessFileName(url, disposition, mime));
                ((android.app.DownloadManager)getSystemService(DOWNLOAD_SERVICE)).enqueue(request);
                Toast.makeText(this,"Download started", Toast.LENGTH_SHORT).show();
            } catch (RuntimeException ex) { external(uri); }
        });
        if (state == null || web.restoreState(state) == null) web.loadUrl(HOME);
    }
    @Override protected void onActivityResult(int request, int result, Intent data) {
        super.onActivityResult(request,result,data);
        if (request == 10 && upload != null) { upload.onReceiveValue(WebChromeClient.FileChooserParams.parseResult(result,data)); upload = null; }
    }
    @Override public void onBackPressed() { if (web.canGoBack()) web.goBack(); else super.onBackPressed(); }
    @Override protected void onSaveInstanceState(Bundle state) { web.saveState(state); super.onSaveInstanceState(state); }
    @Override protected void onPause() { web.onPause(); CookieManager.getInstance().flush(); super.onPause(); }
    @Override protected void onResume() { super.onResume(); if(web != null) web.onResume(); }
    @Override protected void onDestroy() { if(upload != null) upload.onReceiveValue(null); web.destroy(); super.onDestroy(); }
}
