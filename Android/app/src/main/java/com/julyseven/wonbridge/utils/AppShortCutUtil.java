package com.julyseven.wonbridge.utils;

import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.ProviderInfo;
import android.content.pm.ResolveInfo;
import android.content.res.Resources;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.Typeface;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
import android.net.Uri;
import android.os.Build;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.util.Log;
import android.util.TypedValue;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.RestartActivity;

import java.util.Iterator;
import java.util.List;

/**
 * Created by JIS on 10/1/2016.
 */

public class AppShortCutUtil {

    private static final String TAG = "AppShortCutUtil";

    //디폴트 뱃지 반경
    private static final int DEFAULT_CORNER_RADIUS_DIP = 8;
    //디폴트 테두리 너비
    private static final int DEFAULT_STROKE_WIDTH_DIP = 2;
    //테두리 색상
    private static final int DEFAULT_STROKE_COLOR = Color.WHITE;
    //뱃지내 숫자 색상
    private static final int DEFAULT_NUM_COLOR = Color.parseColor("#CCFF0000");


    /***
     *
     * 숫자가 표시되는 뱃지 생성(테두리 없음)
     * @param context 컨텍스트
     * @param icon 아이콘 이미지
     * @param isShowNum 숫자 생성 여부
     * @param num 숫자 문자열：숫자가 99이상일 경우，"99+"로 표시
     * @return
     */
    public static Bitmap generatorNumIcon(Context context, Bitmap icon, boolean isShowNum, String num) {

        DisplayMetrics dm = context.getResources().getDisplayMetrics();
        //기준 화면 밀도
        float baseDensity = 1.5f;//240dpi
        float factor = dm.density/baseDensity;

        Log.e(TAG, "density:"+dm.density);
        Log.e(TAG, "dpi:"+dm.densityDpi);
        Log.e(TAG, "factor:"+factor);

        // 캔버스를 초기화
        int iconSize = (int) context.getResources().getDimension(android.R.dimen.app_icon_size);
        Bitmap numIcon = Bitmap.createBitmap(iconSize, iconSize, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(numIcon);

        // 이미지 복사
        Paint iconPaint = new Paint();
        iconPaint.setDither(true);// 진동방지
        iconPaint.setFilterBitmap(true);// Drawable을 선택시 안티 앨리어싱의 효과를 가질 수 있도록, 필터링 과정을 비트 맵에 사용
        Rect src = new Rect(0, 0, icon.getWidth(), icon.getHeight());
        Rect dst = new Rect(0, 0, iconSize, iconSize);
        canvas.drawBitmap(icon, src, dst, iconPaint);

        if(isShowNum){

            if(TextUtils.isEmpty(num)){
                num = "0";
            }

            if(!TextUtils.isDigitsOnly(num)){
                //숫자가 아님
                Log.e(TAG, "the num is not digit :"+ num);
                num = "0";
            }

            int numInt = Integer.valueOf(num);

            if(numInt > 99){// 99이상일 경우

                num = "99+";

                // 안티 앨리어싱 및 장비 텍스트 크기의 사용을 활성화
                Paint numPaint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.DEV_KERN_TEXT_FLAG);
                numPaint.setColor(Color.WHITE);
                numPaint.setTextSize(20f*factor);
                numPaint.setTypeface(Typeface.DEFAULT_BOLD);
                int textWidth=(int)numPaint.measureText(num, 0, num.length());

                Log.e(TAG, "text width:"+textWidth);

                int circleCenter = (int) (15*factor);// 중심 좌표
                int circleRadius = (int) (13*factor);// 원의 반경

                //왼쪽에 그린 원형
                Paint leftCirPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
                leftCirPaint.setColor(Color.RED);
                canvas.drawCircle(iconSize-circleRadius-textWidth+(10*factor), circleCenter, circleRadius, leftCirPaint);

                //오른쪽에 그린 원형
                Paint rightCirPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
                rightCirPaint.setColor(Color.RED);
                canvas.drawCircle(iconSize-circleRadius, circleCenter, circleRadius, rightCirPaint);

                //중간에 그린 구형
                Paint rectPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
                rectPaint.setColor(Color.RED);
                RectF oval = new RectF(iconSize-circleRadius-textWidth+(10*factor), 2*factor, iconSize-circleRadius, circleRadius*2+2*factor);
                canvas.drawRect(oval, rectPaint);

                //숫자를 구현
                canvas.drawText(num, (float)(iconSize-textWidth/2-(24*factor)), 23*factor,        numPaint);

            }else{//<=99

                // 안티 앨리어싱 및 장비 텍스트 크기의 사용을 활성화
                Paint numPaint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.DEV_KERN_TEXT_FLAG);
                numPaint.setColor(Color.WHITE);
                numPaint.setTextSize(20f*factor);
                numPaint.setTypeface(Typeface.DEFAULT_BOLD);
                int textWidth=(int)numPaint.measureText(num, 0, num.length());

                Log.e(TAG, "text width:"+textWidth);

                //외부 원형을 구현
                //Paint outCirPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
                //outCirPaint.setColor(Color.WHITE);
                //canvas.drawCircle(iconSize - 15, 15, 15, outCirPaint);

                //내부 원형을 구현
                Paint inCirPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
                inCirPaint.setColor(Color.RED);
                canvas.drawCircle(iconSize-15*factor, 15*factor, 15*factor, inCirPaint);

                //숫자를 구현
                canvas.drawText(num, (float)(iconSize-textWidth/2-15*factor), 22*factor, numPaint);
            }
        }
        return numIcon;
    }


    /***
     *
     * 숫자가 표시되는 뱃지 생성(테두리 없음)
     * @param context
     * @param icon 아이콘 이미지
     * @param isShowNum 숫자의 여부
     * @param num 숫자 문자열:99이상일 경우, “99+”로 표시
     * @return
     */
    public static Bitmap generatorNumIcon2(Context context, Bitmap icon, boolean isShowNum, String num) {

        DisplayMetrics dm = context.getResources().getDisplayMetrics();
        //기준 화면 밀도
        float baseDensity = 1.5f;//240dpi
        float factor = dm.density/baseDensity;

        Log.e(TAG, "density:"+dm.density);
        Log.e(TAG, "dpi:"+dm.densityDpi);
        Log.e(TAG, "factor:"+factor);

        // 캔버스를 초기화
        int iconSize = (int) context.getResources().getDimension(android.R.dimen.app_icon_size);
        Bitmap numIcon = Bitmap.createBitmap(iconSize, iconSize, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(numIcon);

        // 이미지를 복제
        Paint iconPaint = new Paint();
        iconPaint.setDither(true);// 진동 방지
        iconPaint.setFilterBitmap(true);// Drawable을 선택시 안티 앨리어싱의 효과를 가질 수 있도록, 필터링 과정을 비트 맵에 사용
        Rect src = new Rect(0, 0, icon.getWidth(), icon.getHeight());
        Rect dst = new Rect(0, 0, iconSize, iconSize);
        canvas.drawBitmap(icon, src, dst, iconPaint);

        if(isShowNum){

            if(TextUtils.isEmpty(num)){
                num = "0";
            }

            if(!TextUtils.isDigitsOnly(num)){
                //숫자가 아님
                Log.e(TAG, "the num is not digit :"+ num);
                num = "0";
            }

            int numInt = Integer.valueOf(num);

            if(numInt > 99){//99이상
                num = "99+";
            }

            //안티 앨리어싱 및 장비 텍스트 크기의 사용을 활성화
            //문자가 차지하는 폭을 측정
            Paint numPaint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.DEV_KERN_TEXT_FLAG);
            numPaint.setColor(Color.WHITE);
            numPaint.setTextSize(20f*factor);
            numPaint.setTypeface(Typeface.DEFAULT_BOLD);
            int textWidth=(int)numPaint.measureText(num, 0, num.length());
            Log.e(TAG, "text width:"+textWidth);

            /**----------------------------------*
             * TODO모서리가 둥근 직사각형 배경을 구현
             *------------------------------------*/
            // 둥근 사각형 배경 폭
            int backgroundHeight = (int) (2*15*factor);
            int backgroundWidth = textWidth>backgroundHeight ? (int)(textWidth+10*factor) : backgroundHeight;

            canvas.save();// 상태를 저장

            ShapeDrawable drawable = getDefaultBackground(context);
            drawable.setIntrinsicHeight(backgroundHeight);
            drawable.setIntrinsicWidth(backgroundWidth);
            drawable.setBounds(0, 0, backgroundWidth, backgroundHeight);
            canvas.translate(iconSize-backgroundWidth, 0);
            drawable.draw(canvas);

            canvas.restore();   //이전에 저장한 상태로 재설정

            /**----------------------------------*
             * TODO 모서리가 둥근 직사각형 배경 구현 end
             *------------------------------------*/

            //숫자를 구현
            canvas.drawText(num, (float)(iconSize-(backgroundWidth + textWidth)/2), 22*factor, numPaint);
        }
        return numIcon;
    }
    /***
     *
     * 숫자 표시되는 뱃지 생성(데두리 있음)
     * @param context
     * @param icon 아이콘 이미지
     * @param isShowNum 숫자 표시 여부
     * @param num 숫자 문자열:99이상일 경우, “99+”로 표시
     * @return
     */
    public static Bitmap generatorNumIcon3(Context context, Bitmap icon, boolean isShowNum, String num) {

        DisplayMetrics dm = context.getResources().getDisplayMetrics();
        //기준 화면 밀도
        float baseDensity = 1.5f;//240dpi
        float factor = dm.density/baseDensity;

        Log.e(TAG, "density:"+dm.density);
        Log.e(TAG, "dpi:"+dm.densityDpi);
        Log.e(TAG, "factor:"+factor);

        // 캔버스를 초기화
        int iconSize = (int) context.getResources().getDimension(android.R.dimen.app_icon_size);
        Bitmap numIcon = Bitmap.createBitmap(iconSize, iconSize, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(numIcon);

        // 이미지를 복제
        Paint iconPaint = new Paint();
        iconPaint.setDither(true);// 진동 방지
        iconPaint.setFilterBitmap(true);// Drawable을 선택시 안티 앨리어싱의 효과를 가질 수 있도록, 필터링 과정을 비트 맵에 사용
        Rect src = new Rect(0, 0, icon.getWidth(), icon.getHeight());
        Rect dst = new Rect(0, 0, iconSize, iconSize);
        canvas.drawBitmap(icon, src, dst, iconPaint);

        if(isShowNum){

            if(TextUtils.isEmpty(num)){
                num = "0";
            }

            if(!TextUtils.isDigitsOnly(num)){
                //숫자가 아님
                Log.e(TAG, "the num is not digit :"+ num);
                num = "0";
            }

            int numInt = Integer.valueOf(num);

            if(numInt > 99){//99이상
                num = "99+";
            }

            //안티 앨리어싱 및 장비 텍스트 크기의 사용을 활성화
            //문자가 차지하는 폭을 측정
            Paint numPaint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.DEV_KERN_TEXT_FLAG);
            numPaint.setColor(Color.WHITE);
            numPaint.setTextSize(20f*factor);
            numPaint.setTypeface(Typeface.DEFAULT_BOLD);
            int textWidth=(int)numPaint.measureText(num, 0, num.length());
            Log.e(TAG, "text width:"+textWidth);

            /**----------------------------------*
             * TODO 모서리가 둥근 직사각형 배경：우선 테두리를 구현한 다음 모서리가 둥근 직사각형을 구현함start
             *------------------------------------*/
            // 둥근 사각형 배경 폭
            int backgroundHeight = (int) (2*15*factor);
            int backgroundWidth = textWidth>backgroundHeight ? (int)(textWidth+10*factor) : backgroundHeight;
            //테두리 폭
            int strokeThickness = (int) (2*factor);

            canvas.save();//상태를 저장

            int strokeHeight = backgroundHeight + strokeThickness*2;
            int strokeWidth = textWidth>strokeHeight ? (int)(textWidth+ 10*factor + 2*strokeThickness) : strokeHeight;
            ShapeDrawable outStroke = getDefaultStrokeDrawable(context);
            outStroke.setIntrinsicHeight(strokeHeight);
            outStroke.setIntrinsicWidth(strokeWidth);
            outStroke.setBounds(0, 0, strokeWidth, strokeHeight);
            canvas.translate(iconSize-strokeWidth-strokeThickness, strokeThickness);
            outStroke.draw(canvas);

            canvas.restore();//이전에 저장한 상태로 재설정

            canvas.save();//상태를 저장

            ShapeDrawable drawable = getDefaultBackground(context);
            drawable.setIntrinsicHeight((int) (backgroundHeight+2*factor));
            drawable.setIntrinsicWidth((int) (backgroundWidth+2*factor));
            drawable.setBounds(0, 0, backgroundWidth, backgroundHeight);
            canvas.translate(iconSize-backgroundWidth-2*strokeThickness, 2*strokeThickness);
            drawable.draw(canvas);

            canvas.restore();//이전에 저장한 상태로 재설정

            /**----------------------------------*
             * TODO 모서리가 둥근 직사각형 배경 구현 end
             *------------------------------------*/

            //숫자를 구현
            canvas.drawText(num, (float)(iconSize-(backgroundWidth + textWidth+4*strokeThickness)/2), (22)*factor+2*strokeThickness, numPaint);
        }
        return numIcon;
    }

    /***
     *
     * 숫자가 표시되는 뱃지 생성(테두리 있음)
     * @param context
     * @param icon 아이콘 이미지
     * @param isShowNum
     * @param num 숫자 문자열：99이상일 경우， "99+"로 표시
     * @return
     */
    public static Bitmap generatorNumIcon4(Context context, Bitmap icon, boolean isShowNum, String num) {

        DisplayMetrics dm = context.getResources().getDisplayMetrics();
        //기준 화면 밀도
        float baseDensity = 1.5f;//240dpi
        float factor = dm.density/baseDensity;

        Log.e(TAG, "density:"+dm.density);
        Log.e(TAG, "dpi:"+dm.densityDpi);
        Log.e(TAG, "factor:"+factor);

        // 캔버스를 초기화
        int iconSize = (int) context.getResources().getDimension(android.R.dimen.app_icon_size);
        Bitmap numIcon = Bitmap.createBitmap(iconSize, iconSize, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(numIcon);

        // 이미지를 복제
        Paint iconPaint = new Paint();
        iconPaint.setDither(true);// 진동 방지
        iconPaint.setFilterBitmap(true);// Drawable을 선택시 안티 앨리어싱의 효과를 가질 수 있도록, 필터링 과정을 비트 맵에 사용
        Rect src = new Rect(0, 0, icon.getWidth(), icon.getHeight());
        Rect dst = new Rect(0, 0, iconSize, iconSize);
        canvas.drawBitmap(icon, src, dst, iconPaint);

        if(isShowNum){

            if(TextUtils.isEmpty(num)){
                num = "0";
            }

            if(!TextUtils.isDigitsOnly(num)){
                //숫자가 아님
                Log.e(TAG, "the num is not digit :"+ num);
                num = "0";
            }

            int numInt = Integer.valueOf(num);

            if(numInt > 99){//99이상
                num = "99+";
            }

            //안티 앨리어싱 및 장비 텍스트 크기의 사용을 활성화
            //문자가 차지하는 폭을 측정
            Paint numPaint = new Paint(Paint.ANTI_ALIAS_FLAG | Paint.DEV_KERN_TEXT_FLAG);
            numPaint.setColor(Color.WHITE);
            numPaint.setTextSize(25f*factor);
            numPaint.setTypeface(Typeface.DEFAULT_BOLD);
            int textWidth=(int)numPaint.measureText(num, 0, num.length());
            Log.e(TAG, "text width:"+textWidth);

            /**----------------------------------*
             * TODO모서리가 둥근 직사각형 배경을 구현. 우선 테두리를 그린 후 내부의 모서리가 둥근 직사각형을 완성함 Start
             *------------------------------------*/
            //테두리 폭
            int strokeThickness = (int) (DEFAULT_STROKE_WIDTH_DIP*factor);
            //둥근 사각형 배경 폭
            float radiusPx = 15*factor;
            int backgroundHeight = (int) (2*(radiusPx+strokeThickness));//2*(반경+테두리 폭)
            int backgroundWidth = textWidth>backgroundHeight ? (int)(textWidth + 10*factor + 2*strokeThickness) : backgroundHeight;

            canvas.save();//상태를 저장

            ShapeDrawable drawable = getDefaultBackground2(context);
            drawable.setIntrinsicHeight(backgroundHeight);
            drawable.setIntrinsicWidth(backgroundWidth);
            drawable.setBounds(0, 0, backgroundWidth, backgroundHeight);
            canvas.translate(iconSize-backgroundWidth-strokeThickness, 2*strokeThickness);
            drawable.draw(canvas);

            canvas.restore();//이전에 저장한 상태로 재설정

            /**----------------------------------*
             * TODO 모서리가 둥근 직사각형 배경 구현 end
             *------------------------------------*/

            //숫자를 구현
            canvas.drawText(num, (float)(iconSize-(backgroundWidth + textWidth+2*strokeThickness)/2), (float) (25*factor+2.5*strokeThickness), numPaint);
        }
        return numIcon;
    }

    /***
     * 네이티브 시스템의 Shortcut를 생성
     * @param context
     * @param clazz 구동한activity
     * @param isShowNum 숫자 표시 여부
     * @param num 표시된 숫자
     * @param isStroke 테두리 추가 여부
     */

    public static void installRawShortCut(Context context, Class<?> clazz, boolean isShowNum, String num, boolean isStroke) {
        Log.e(TAG, "installShortCut....");

        Intent shortcutIntent = new Intent("com.android.launcher.action.INSTALL_SHORTCUT");
        //명칭
        shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_NAME,context.getString(R.string.app_name));

        // Shortcut의 중복 생성 여부, true일 경우 중복 생성 가능함, false일 경우 불가능.
        shortcutIntent.putExtra("duplicate", false);

        //Shortcut를 클릭：activity를 열다
        Intent mainIntent = new Intent(Intent.ACTION_MAIN);
        mainIntent.addCategory(Intent.CATEGORY_LAUNCHER);
        mainIntent.setClass(context, clazz);
        shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_INTENT, mainIntent);

        //Shortcut 아이콘
        if(isStroke){
            shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_ICON,
                    generatorNumIcon4(
                            context,
                            ((BitmapDrawable)context.getResources().getDrawable(R.mipmap.ic_launcher)).getBitmap(),
                            isShowNum,
                            num));
        }else{
            shortcutIntent.putExtra(Intent.EXTRA_SHORTCUT_ICON,
                    generatorNumIcon2(
                            context,
                            ((BitmapDrawable)context.getResources().getDrawable(R.mipmap.ic_launcher)).getBitmap(),
                            isShowNum,
                            num));
        }
        context.sendBroadcast(shortcutIntent);
    }


    /***
     * 이미 Shortcut를 생성했는지를 판단
     * @param context
     * @return
     */
    public static boolean isAddShortCut(Context context) {
        Log.e(TAG, "isAddShortCut....");

        boolean isInstallShortcut = false;
        final ContentResolver cr = context.getContentResolver();

        //TODO 메모한 부분의 코드는 ROM을 수정한 시스템을 지원하지 않음
            /*int versionLevel = android.os.Build.VERSION.SDK_INT;
                        String AUTHORITY = "com.android.launcher2.settings";
                        //2.2이상의 시스템에서는 파일명칭이 다름
                        if (versionLevel >= 8) {
                            AUTHORITY = "com.android.launcher2.settings";
                        } else {
                            AUTHORITY = "com.android.launcher.settings";
                        }*/

        String AUTHORITY = getAuthorityFromPermission(context, "com.android.launcher.permission.READ_SETTINGS");
        Log.e(TAG, "AUTHORITY  :  " +AUTHORITY);
        final Uri CONTENT_URI = Uri.parse("content://" + AUTHORITY
                + "/favorites?notify=true");

        Cursor c = cr.query(CONTENT_URI,
                new String[] { "title" }, "title=?",
                new String[] { context.getString(R.string.app_name) }, null);

        if (c != null && c.getCount() > 0) {
            isInstallShortcut = true;
        }

        if(c != null){
            c.close();
        }

        Log.e(TAG, "isAddShortCut....isInstallShortcut="+isInstallShortcut);

        return isInstallShortcut;
    }

    /**
     * Shortcut 아이콘을 삭제
     * @param context
     * @param clazz
     */
    public static void deleteShortCut(Context context, Class<?> clazz){
        Log.e(TAG, "delShortcut....");

        if (Build.MANUFACTURER.equalsIgnoreCase("Xiaomi")){
            //XIAOMI
            // ""일 경우, 숫자를 표지하지 않음, 숨긴 상태와 같음)
            xiaoMiShortCut(context, clazz, "");

        }else if(Build.MANUFACTURER.equalsIgnoreCase("samsung")){
            //삼성
            samsungShortCut(context, "0");

        }else {//기타 네이티브 시스템 휴대폰
            //숫자 표시을 삭제하는 Shortcut
            deleteRawShortCut(context, clazz);
            //숫자를 표시하지 않는 Shortcut를 설치
            //installRawShortCut(context, clazz, false, "0");
        }
    }

    /***
     * 네이티브 시스템의 Shortcut를 삭제
     * @param context
     * @param clazz 启动的activity
     */
    public static void deleteRawShortCut(Context context, Class<?> clazz) {
        Intent intent = new Intent("com.android.launcher.action.UNINSTALL_SHORTCUT");
        //Shortcut 명칭
        intent.putExtra(Intent.EXTRA_SHORTCUT_NAME, context.getString(R.string.app_name));

        Intent intent2 = new Intent();
        intent2.setClass(context, clazz);
        intent2.setAction(Intent.ACTION_MAIN);
        intent2.addCategory(Intent.CATEGORY_LAUNCHER);
        intent.putExtra(Intent.EXTRA_SHORTCUT_INTENT,intent2);

        context.sendBroadcast(intent);
    }


    /***
     * 권한 관련 인증URI를 획득
     * @param context
     * @param permission
     * @return
     */
    public static String getAuthorityFromPermission(Context context, String permission) {
        if (TextUtils.isEmpty(permission)) {
            return null;
        }
        List<PackageInfo> packInfos = context.getPackageManager().getInstalledPackages(PackageManager.GET_PROVIDERS);
        if (packInfos == null) {
            return null;
        }
        for (PackageInfo info : packInfos) {
            ProviderInfo[] providers = info.providers;
            if (providers != null) {
                for (ProviderInfo provider : providers) {
                    if (permission.equals(provider.readPermission)
                            || permission.equals(provider.writePermission)) {
                        return provider.authority;
                    }
                }
            }
        }
        return null;
    }

    /***
     * XIAOMI APP아이콘의 Shortcut에 숫자를 추가
     *
     *
     * @param context
     * @param num 표시된 숫자가 99이상일 경우, “99”. 표시하지 않을 경우 “”로 설정(숨긴 상태와 같음)
     *
     * 주의사항：
     * context.getPackageName()+"/."+clazz.getSimpleName() （이것은activity를 구동하는 경로）중의 "/." 는 필수
     *
     */
    public static void xiaoMiShortCut(Context context,Class<?> clazz, String num)
    {
        Log.e(TAG, "xiaoMiShortCut....");
        Intent localIntent = new Intent("android.intent.action.APPLICATION_MESSAGE_UPDATE");
        localIntent.putExtra("android.intent.extra.update_application_component_name", context.getPackageName()+"/."+clazz.getSimpleName());
        if(TextUtils.isEmpty(num)){
            num = "";
        }else{
            int numInt = Integer.valueOf(num);
            if (numInt > 0){
                if (numInt > 99){
                    num = "99";
                }
            }else{
                num = "0";
            }
        }
        localIntent.putExtra("android.intent.extra.update_application_message_text", num);
        context.sendBroadcast(localIntent);
    }

    /***
     * Sony휴대폰: APP 아이콘의 Shortcut에 숫자를 추가
     * @param context
     * @param num
     */
    public static void sonyShortCut(Context context, String num)
    {
        String activityName = getLaunchActivityName(context);
        if (activityName == null){
            return;
        }
        Intent localIntent = new Intent();
        int numInt = Integer.valueOf(num);
        boolean isShow = true;
        if (numInt < 1){
            num = "";
            isShow = false;
        }else if (numInt > 99){
            num = "99";
        }
        localIntent.putExtra("com.sonyericsson.home.intent.extra.badge.SHOW_MESSAGE", isShow);
        localIntent.setAction("com.sonyericsson.home.action.UPDATE_BADGE");
        localIntent.putExtra("com.sonyericsson.home.intent.extra.badge.ACTIVITY_NAME", activityName);
        localIntent.putExtra("com.sonyericsson.home.intent.extra.badge.MESSAGE", num);
        localIntent.putExtra("com.sonyericsson.home.intent.extra.badge.PACKAGE_NAME", context.getPackageName());
        context.sendBroadcast(localIntent);
    }

    /***
     * 삼성 휴대폰：APP 아이콘의 Shortcut에 숫자를 추가
     * @param context
     * @param num
     */
    public static void samsungShortCut(Context context, String num)
    {
        int numInt = Integer.valueOf(num);
        if (numInt < 1)
        {
            num = "0";
        }else if (numInt > 99){
            num = "99";
        }

        if (numInt > 99)
            numInt = 99;

        String activityName = getLaunchActivityName(context);
        Intent localIntent = new Intent("android.intent.action.BADGE_COUNT_UPDATE");
        localIntent.putExtra("badge_count", numInt);
        localIntent.putExtra("badge_count_package_name", context.getPackageName());
        localIntent.putExtra("badge_count_class_name", activityName);
        context.sendBroadcast(localIntent);
    }

    /***
     * APP 아이콘의 Shortcut에 숫자를 추가
     * @param clazz 구동한activity
     * @param isShowNum 숫자 표시 여부
     * @param num 표시된 숫자
     * @param isStroke 테두리 추가 여부
     *
     */
    public static void addNumShortCut(Context context,Class<?> clazz,boolean isShowNum, String num, boolean isStroke)
    {
        Log.e(TAG, "manufacturer="+Build.MANUFACTURER);
        if (Build.MANUFACTURER.equalsIgnoreCase("Xiaomi")){
            //XIAOMI
            xiaoMiShortCut(context, clazz, num);

        }else if(Build.MANUFACTURER.equalsIgnoreCase("samsung")){
            //삼성
            samsungShortCut(context, num);

        }else {//기타 네이티브 시스템 휴대폰
            installRawShortCut(context, RestartActivity.class, isShowNum, num, isStroke);
        }

    }

    /***
     * 현재 APP의 구동 activity 명칭을 획득：
     * mainfest.xml중 스팩의android:name:"
     * @param context
     * @return
     */
    public static String getLaunchActivityName(Context context)
    {
        PackageManager localPackageManager = context.getPackageManager();
        Intent localIntent = new Intent("android.intent.action.MAIN");
        localIntent.addCategory("android.intent.category.LAUNCHER");
        try
        {
            Iterator<ResolveInfo> localIterator = localPackageManager.queryIntentActivities(localIntent, 0).iterator();
            while (localIterator.hasNext())
            {
                ResolveInfo localResolveInfo = localIterator.next();
                if (!localResolveInfo.activityInfo.applicationInfo.packageName.equalsIgnoreCase(context.getPackageName()))
                    continue;
                String str = localResolveInfo.activityInfo.name;
                return str;
            }
        }
        catch (Exception localException)
        {
            return null;
        }
        return null;
    }

    /***
     * 하나의 디폴트 배경을 획득：모서리가 둥근 직사각형
     * 코드로 하나의 배경을 생성： <shape>의 xml의 배경을 사용한 것과 같음
     *
     * @return
     */
    private static ShapeDrawable getDefaultBackground(Context context) {

        //이것은 부동한 해상도의 휴대폰에 대응하기 위함임 디스플레이 호환성
        int r = dipToPixels(context,DEFAULT_CORNER_RADIUS_DIP);
        float[] outerR = new float[] {r, r, r, r, r, r, r, r};

        //모서리가 둥근 직사각형
        RoundRectShape rr = new RoundRectShape(outerR, null, null);
        ShapeDrawable drawable = new ShapeDrawable(rr);
        drawable.getPaint().setColor(DEFAULT_NUM_COLOR);//색상을 설정
        return drawable;

    }
    /***
     * 하나의 디폴트 배경을 획득：모서리가 둥근 직사각형
     * 코드로 하나의 배경을 생성： <shape>의 xml의 배경을 사용한 것과 같음
     *
     * @return
     */
    private static ShapeDrawable getDefaultBackground2(Context context) {

        //이것은 부동한 해상도의 휴대폰에 대응하기 위함임 디스플레이 호환성
        int r = dipToPixels(context,DEFAULT_CORNER_RADIUS_DIP);
        float[] outerR = new float[] {r, r, r, r, r, r, r, r};
        int distance = dipToPixels(context,DEFAULT_STROKE_WIDTH_DIP);

        //모서리가 둥근 직사각형
        RoundRectShape rr = new RoundRectShape(outerR, null, null);
        ShapeDrawable drawable = new ShapeDrawable(rr);
        drawable.getPaint().setColor(DEFAULT_NUM_COLOR);//색상을 설정

        return drawable;

    }


    /***
     * 하나의 디폴트 배경을 획득：모서리가 둥근 직사각형
     * 코드로 하나의 배경을 생성： <shape>의 xml의 배경을 사용한 것과 같음
     *
     * @return
     */
    private static ShapeDrawable getDefaultStrokeDrawable(Context context) {

        //이것은 부동한 해상도의 휴대폰에 대응하기 위함임 디스플레이 호환성
        int r = dipToPixels(context, DEFAULT_CORNER_RADIUS_DIP);
        int distance = dipToPixels(context, DEFAULT_STROKE_WIDTH_DIP);
        float[] outerR = new float[] {r, r, r, r, r, r, r, r};

        //모서리가 둥근 직사각형
        RoundRectShape rr = new RoundRectShape(outerR, null, null);
        ShapeDrawable drawable = new ShapeDrawable(rr);
        drawable.getPaint().setStrokeWidth(distance);
        drawable.getPaint().setStyle(Paint.Style.FILL);
        drawable.getPaint().setColor(DEFAULT_STROKE_COLOR);// 색상을 설정
        return drawable;
    }

    /***
     * dp to px
     * @param dip
     * @return
     */
    public static int dipToPixels(Context context, int dip) {
        Resources r = context.getResources();
        float px = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dip, r.getDisplayMetrics());
        return (int) px;
    }
}

