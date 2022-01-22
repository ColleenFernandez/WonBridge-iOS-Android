package com.julyseven.wonbridge;

import android.app.Application;
import android.text.TextUtils;

import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.toolbox.ImageLoader;
import com.android.volley.toolbox.Volley;
import com.baidu.mapapi.SDKInitializer;
import com.julyseven.wonbridge.utils.LruBitmapCache;
import com.nostra13.universalimageloader.cache.disc.naming.Md5FileNameGenerator;
import com.nostra13.universalimageloader.core.ImageLoaderConfiguration;


/**
 * Created by sss on 8/21/2016.
 */
public class WonBridgeApplication extends Application {

    public static final String TAG = WonBridgeApplication.class.getSimpleName();

    public RequestQueue _requestQueue;
    public ImageLoader _imageLoader;

    private String m_gsmToken = "";

    private static WonBridgeApplication _instance;

    @Override
    public void onCreate(){

        super.onCreate();
        _instance = this;

        SDKInitializer.initialize(this);

        // This configuration tuning is custom. You can tune every option, you may tune some of them,
        // or you can create default configuration by
        //  ImageLoaderConfiguration.createDefault(this);
        // method.
        ImageLoaderConfiguration config = new ImageLoaderConfiguration.Builder(getApplicationContext())
                .threadPoolSize(3)
                .threadPriority(Thread.NORM_PRIORITY - 2)
                .memoryCacheSize(1500000) // 1.5 Mb
                .denyCacheImageMultipleSizesInMemory()
                .discCacheFileNameGenerator(new Md5FileNameGenerator())
                .enableLogging() // Not necessary in common
                .build();
        // Initialize ImageLoader with configuration.
        com.nostra13.universalimageloader.core.ImageLoader.getInstance().init(config);

    }

    public String getGcmToken() {
        return m_gsmToken;
    }

    public void setGcmToken(String p_strGsmToken) {
        m_gsmToken = p_strGsmToken;
    }

    public static synchronized WonBridgeApplication getInstance(){

        return _instance;
    }

    public RequestQueue getRequestQueue(){

        if(_requestQueue == null){
            _requestQueue = Volley.newRequestQueue(getApplicationContext());
        }

        return _requestQueue;
    }

    public ImageLoader getImageLoader(){

        getRequestQueue();
        if(_imageLoader == null){
            _imageLoader = new ImageLoader(this._requestQueue, new LruBitmapCache());
        }
        return this._imageLoader;
    }

    public <T> void addToRequestQueue(Request<T> req, String tag){

        // set the default tag if tag is empty
        req.setTag(TextUtils.isEmpty(tag) ? TAG : tag);
        getRequestQueue().add(req);
    }

    public <T> void addToRequestQueue(Request<T> req) {
        req.setTag(TAG);
        getRequestQueue().add(req);
    }

    public void cancelPendingRequests(Object tag) {
        if (_requestQueue != null) {
            _requestQueue.cancelAll(tag);
        }
    }
}
