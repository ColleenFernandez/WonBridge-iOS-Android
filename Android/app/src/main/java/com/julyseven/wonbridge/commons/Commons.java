package com.julyseven.wonbridge.commons;

import android.content.Context;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.os.Build;
import android.provider.Settings;
import android.support.v4.app.ActivityCompat;
import android.util.Log;
import android.util.TypedValue;

import com.julyseven.wonbridge.Chatting.CallRequestActivity;
import com.julyseven.wonbridge.Chatting.ConnectionMgrService;
import com.julyseven.wonbridge.Chatting.GroupChattingActivity;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.RestartActivity;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.base.CommonTabActivity;
import com.julyseven.wonbridge.model.CountryEntity;
import com.julyseven.wonbridge.model.TimelineEntity;
import com.julyseven.wonbridge.model.UserEntity;
import com.julyseven.wonbridge.preference.PrefConst;
import com.julyseven.wonbridge.preference.Preference;
import com.julyseven.wonbridge.utils.AppShortCutUtil;

import org.appspot.apprtc.CallActivity;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import me.leolin.shortcutbadger.ShortcutBadger;

import static android.content.ContentValues.TAG;
import static com.julyseven.wonbridge.utils.AppShortCutUtil.installRawShortCut;
import static com.julyseven.wonbridge.utils.AppShortCutUtil.samsungShortCut;
import static com.julyseven.wonbridge.utils.AppShortCutUtil.xiaoMiShortCut;

/**
 * Created by sss on 8/21/2016.
 */
public class Commons {

    public static boolean g_isAppRunning=false;
    public static boolean g_isAppPaused=false;

    public static String q_recentphotoPath=null;
    public static Bitmap q_recentBitmap=null;

    public static UserEntity g_user = null;

    public static int g_badgCount=0;
    public static CommonTabActivity g_currentActivity = null;

    public static GroupChattingActivity g_chattingActivity = null;
    public static GroupChattingActivity g_onlineActivity = null;

    public static ConnectionMgrService g_xmppService = null;

    public static CommonActivity g_commonActivity = null;

    public static CallRequestActivity g_callRequestActivity = null;
    public static CallActivity g_callActivity = null;

    public static boolean g_isFirstLocCaptured = false;

    public static boolean g_isChina = false;

    public static boolean g_isSocialLogin = false;

    public static TimelineEntity g_notiData = null;


    public static int GetPixelValueFromDp(Context context, float dp_value) {

        int pxValue = (int) TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, dp_value, context.getResources()
                        .getDisplayMetrics());

        return pxValue;
    }

    public static String idxToAddr(int idx) {
        return idx + "@" + ReqConst.CHATTING_SERVER;
    }

    public static int addrToIdx(String addr) {
        int pos = addr.indexOf("@");
        return Integer.valueOf(addr.substring(0, pos)).intValue();
    }

    public static String fileExtFromUrl(String url) {

        if (url.indexOf("?") > -1) {
            url = url.substring(0, url.indexOf("?"));
        }

        if (url.lastIndexOf(".") == -1) {
            return url;
        } else {
            String ext = url.substring(url.lastIndexOf(".") );
            if (ext.indexOf("%") > -1) {
                ext = ext.substring(0, ext.indexOf("%"));
            }
            if (ext.indexOf("/") > -1) {
                ext = ext.substring(0, ext.indexOf("/"));
            }
            return ext.toLowerCase();
        }
    }

    public static String fileNameWithExtFromUrl(String url) {

        if (url.indexOf("?") > -1) {
            url = url.substring(0, url.indexOf("?"));
        }

        if (url.lastIndexOf("/") == -1) {
            return url;
        } else {
            String name = url.substring(url.lastIndexOf("/")  + 1);
            return name;
        }
    }

    public static String fileNameWithoutExtFromUrl(String url) {

        String fullname = fileNameWithExtFromUrl(url);

        if (fullname.lastIndexOf(".") == -1) {
            return fullname;
        } else {
            return fullname.substring(0, fullname.lastIndexOf("."));
        }
    }

    public static String fileNameWithExtFromPath(String path) {

        if (path.lastIndexOf("/") > -1)
            return path.substring(path.lastIndexOf("/") + 1);

        return path;
    }

    public static String fileNameWithoutExtFromPath(String path) {

        String fullname = fileNameWithExtFromPath(path);

        if (fullname.lastIndexOf(".") == -1) {
            return fullname;
        } else {
            return fullname.substring(0, fullname.lastIndexOf("."));
        }
    }

    public static boolean isValidMail(String email)
    {
        boolean check;
        Pattern p;
        Matcher m;

        String EMAIL_STRING = "^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@"
                + "[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";

        p = Pattern.compile(EMAIL_STRING);

        m = p.matcher(email);
        check = m.matches();

        return check;
    }

    public static boolean isValidMobile(String phone)
    {
        boolean check = false;

        if(!Pattern.matches("[a-zA-Z]+", phone))
        {
            if(phone.length() < 6 || phone.length() > 12)
            {
                check = false;
            }
            else
            {
                check = true;
            }
        }
        else
        {
            check=false;
        }

        return check;
    }


    // local time
    public static String getChattingDisplayTime(String fullTime) {

        Date when;

        if (fullTime.length() == 0)
            return fullTime;

        SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd,HH:mm:ss");

        try {
            when = df.parse(fullTime);

        } catch (Exception ex) {
            ex.printStackTrace();
            return fullTime;
        }

        Calendar calWhen = Calendar.getInstance();
        calWhen.setTime(when);
        calWhen.set(Calendar.HOUR_OF_DAY, 0);
        calWhen.set(Calendar.HOUR, 0);
        calWhen.set(Calendar.MINUTE, 0);
        calWhen.set(Calendar.SECOND, 0);
        calWhen.set(Calendar.MILLISECOND, 0);

        Calendar calNow = Calendar.getInstance();
        calNow.set(Calendar.HOUR_OF_DAY, 0);
        calNow.set(Calendar.HOUR, 0);
        calNow.set(Calendar.MINUTE, 0);
        calNow.set(Calendar.SECOND, 0);
        calNow.set(Calendar.MILLISECOND, 0);

        long days = (calNow.getTimeInMillis() - calWhen.getTimeInMillis()) / 1000 / 60 / 60 / 24;
        long months = days / 30;
        long years = days / 365;

        if (days == 0) {

            fullTime = fullTime.split(",")[1];

            String time = "";

            int hour = Integer.valueOf(fullTime.split(":")[0]);
            String min = fullTime.split(":")[1];

            if (hour < 12) {
                time = Commons.g_currentActivity.getString(R.string.am) + " " + hour + ":" + min;
            } else {
                hour -= 12;
                if (hour == 0)
                    hour = 12;
                time = Commons.g_currentActivity.getString(R.string.pm) + " " + hour + ":" + min;
            }

            return time;

        } else if (days < 31) {
            return ((days == 1)? Commons.g_currentActivity.getString(R.string.last_day) : days + Commons.g_currentActivity.getString(R.string.days_ago));
        } else if (months < 13) {
            return ((months == 1)? Commons.g_currentActivity.getString(R.string.last_month) : months + Commons.g_currentActivity.getString(R.string.months_ago));
        } else {
            return ((years == 1)? Commons.g_currentActivity.getString(R.string.last_year) : years + Commons.g_currentActivity.getString(R.string.years_ago));
        }


    }

    // 20150101,13:30:26 or 20160103,6:07:06
    public static String getCurrentUTCTimeString() {

        TimeZone utcTimeZone = TimeZone.getTimeZone("UTC");
        Calendar now = Calendar.getInstance(utcTimeZone);

        int year = now.get(Calendar.YEAR);
        int month = now.get(Calendar.MONTH) + 1;
        int date = now.get(Calendar.DATE);

        String time = String.format("%d%02d%02d", year, month, date);

        int hour = now.get(Calendar.HOUR_OF_DAY);
        int min = now.get(Calendar.MINUTE);
        int sec = now.get(Calendar.SECOND);

        time += String.format(",%02d:%02d:%02d", hour, min, sec);

        return time;
    }

    // 20150101,13:30:26 or 20160103,6:07:06
    public static String getCurrentTimeString() {

        Calendar now = Calendar.getInstance();

        int year = now.get(Calendar.YEAR);
        int month = now.get(Calendar.MONTH) + 1;
        int date = now.get(Calendar.DATE);

        String time = String.format("%d%02d%02d", year, month, date);

        int hour = now.get(Calendar.HOUR_OF_DAY);
        int min = now.get(Calendar.MINUTE);
        int sec = now.get(Calendar.SECOND);

        time += String.format(",%02d:%02d:%02d", hour, min, sec);

        return time;
    }

    // yyyy-MM-dd HH:mm:ss
    public static String getDisplayLocalTimeString(String utcTime) {

        String fullTime = "";

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"));

        Date when = new Date();
        try {

            when = sdf.parse(utcTime);

            sdf = new SimpleDateFormat("yyyyMMdd,HH:mm:ss");
            fullTime = sdf.format(when);

        }catch (Exception ex) {
        }

        if (fullTime.length() == 0)
            return fullTime;

        Calendar calWhen = Calendar.getInstance();
        calWhen.setTime(when);

        Calendar calNow = Calendar.getInstance();

        long mins = (calNow.getTimeInMillis() - calWhen.getTimeInMillis()) / 1000 / 60;
        long hours = mins / 60;
        long days = hours / 24;
        long months = days / 30;
        long years = days / 365;

        if (mins <= 0) {
            return Commons.g_currentActivity.getString(R.string.just_now);
        } else if (hours == 0) {
            return mins + Commons.g_currentActivity.getString(R.string.mins_ago);
        } else if (days == 0) {
            return hours + Commons.g_currentActivity.getString(R.string.hours_ago);
        } else if (days == 1) {
            return Commons.g_currentActivity.getString(R.string.last_day);
        } else if (days < 31) {
            return days + Commons.g_currentActivity.getString(R.string.days_ago);
        } else if (months == 1) {
            return Commons.g_currentActivity.getString(R.string.last_month);
        } else if (months < 25) {
            return months + Commons.g_currentActivity.getString(R.string.months_ago);
        } else {
            return years + Commons.g_currentActivity.getString(R.string.years_ago);
        }

    }


    // yyyy-MM-dd HH:mm:ss
    public static String getDisplayRegTimeString(String utcTime) {

        String fullTime = "";

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        sdf.setTimeZone(TimeZone.getTimeZone("UTC"));

        try {

            Date when = sdf.parse(utcTime);

            sdf = new SimpleDateFormat("yyyy.MM.dd");
            fullTime = sdf.format(when);

        } catch (Exception ex) {
        }

        return fullTime;

    }

    // yyyy-MM-dd HH:mm:ss to 20150101,13:30:26
    public static String convertTimeString(String utcTime) {

        String fullTime = "";

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        try {

            Date when = sdf.parse(utcTime);

            sdf = new SimpleDateFormat("yyyyMMdd,HH:mm:ss");
            fullTime = sdf.format(when);

        } catch (Exception ex) {
        }

        return fullTime;

    }

    public static boolean hasPermissions(Context context, String... permissions) {

        if (android.os.Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && context != null && permissions != null) {

            for (String permission : permissions) {

                if (ActivityCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                    return false;
                }
            }
        }
        return true;
    }


    public static float calcDistance(float lat1, float lng1, float lat2, float lng2) {

        Location locationA = new Location("point A");
        locationA.setLatitude(lat1);
        locationA.setLongitude(lng1);
        Location locationB = new Location("point B");
        locationB.setLatitude(lat2);
        locationB.setLongitude(lng2);
        return locationA.distanceTo(locationB) / 1000;
    }


    public static String getGeoLocation(Context context, double latitude, double longitude) {

        String addressString = "";

        try {

            Geocoder gc = new Geocoder(context);

            List<Address> addresses = gc
                    .getFromLocation(latitude, longitude, 1);

            StringBuilder sb = new StringBuilder();

            if (addresses.size() > 0) {

                Address address = addresses.get(0);

                if (address.getAdminArea() != null)
                    sb.append(address.getAdminArea()).append(" ");
                if (address.getLocality() != null)
                    sb.append(address.getLocality()).append(" ");
                if (address.getSubLocality() != null)
                    sb.append(address.getSubLocality() + " ");
                if (address.getThoroughfare() != null)
                    sb.append(address.getThoroughfare()).append(" ");

                addressString = sb.toString();

            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        return addressString;
    }

    public static String getCountryCode(Context context){

        String locale = context.getResources().getConfiguration().locale.getCountry();
        return locale;
    }

    public static String getPhoneCode(Context context) {

        String[] phoneCodesList = context.getResources().getStringArray(R.array.CountryPhoneCodesList);

        for (String countryCode : phoneCodesList) {

            String[] itemText = countryCode.split(",");

            if (itemText[1].equalsIgnoreCase(getCountryCode(context)))
                return "+" + itemText[0];

        }

        return "+86";
    }

    public static String getCountryName(Context context) {
        return context.getResources().getConfiguration().locale.getDisplayCountry();
    }

    public static String getCountryName(String countryCode) {

        Locale loc = new Locale("",countryCode);
        return  loc.getDisplayCountry();
    }

    public static String getDurationString(int duration) {

        int seconds = duration / 1000;
        int mins = seconds / 60;
        int hours = mins / 60;

        if (hours > 0) {
            return String.format("%d:%02d:%02d", hours, mins % 60, seconds % 60);
        } else {
            return String.format("%02d:%02d", mins % 60, seconds % 60);
        }

    }

    public static void addNumShortCut(Context context,Class<?> clazz,boolean isShowNum, String num, boolean isStroke) {

        if (Build.MANUFACTURER.equalsIgnoreCase("Xiaomi")){
//            AppShortCutUtil.xiaoMiShortCut(context, clazz, num);

            ShortcutBadger.applyCount(context, Integer.parseInt(num));

        } else if(Build.MANUFACTURER.equalsIgnoreCase("samsung")){
            AppShortCutUtil.samsungShortCut(context, num);

        } else {    // other
            AppShortCutUtil.installRawShortCut(context, clazz, isShowNum, num, isStroke);
        }
    }


    public static String getFileNameFromUrl(String url) {

        String fileName = url.substring( url.lastIndexOf('/')+1, url.length() );

        String fileNameWithoutExtn = fileName.substring(0, fileName.lastIndexOf('.'));

        return fileNameWithoutExtn;
    }

    public static String getFileNameWithExtFromUrl(String url) {

        String fileName = url.substring( url.lastIndexOf('/')+1, url.length() );

        String fileNameWithoutExtn = fileName.substring(0, fileName.lastIndexOf('.'));

        return fileName;
    }

    public static String getDeviceId(Context context) {

        String udid = Preference.getInstance().getValue(context, PrefConst.PREFKEY_DEVICEID, null);

        if (udid == null) {
            udid = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ANDROID_ID);
            Preference.getInstance().put(context, PrefConst.PREFKEY_DEVICEID, udid);
        }

        return udid;
    }

}
