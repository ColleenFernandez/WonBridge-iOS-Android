package com.julyseven.wonbridge.adapter;

import android.graphics.Bitmap;
import android.util.SparseBooleanArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.julyseven.wonbridge.Chatting.GroupChattingActivity;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.timeline.SelectImageActivity;
import com.nostra13.universalimageloader.core.DisplayImageOptions;
import com.nostra13.universalimageloader.core.ImageLoader;
import com.nostra13.universalimageloader.core.assist.SimpleImageLoadingListener;

import java.util.ArrayList;

/**
 * Created by IronP on 8/26/2016.
 */
public class ImageGalleryAdapter extends BaseAdapter {

    private DisplayImageOptions options;
    protected ImageLoader imageLoader = ImageLoader.getInstance();
    ArrayList<String> mList;
    LayoutInflater mInflater;
    CommonActivity mContext;
    SparseBooleanArray mSparseBooleanArray;

    public ImageGalleryAdapter(CommonActivity context, ArrayList<String> imageList) {

        // TODO Auto-generated constructor stub
        mContext = context;
        mInflater = LayoutInflater.from(mContext);
        mSparseBooleanArray = new SparseBooleanArray();
        mList = new ArrayList<String>();
        this.mList = imageList;

        options = new DisplayImageOptions.Builder()
                .showStubImage(R.drawable.placeholder)
                .showImageForEmptyUri(R.drawable.placeholder)
                .cacheInMemory()
                .cacheOnDisc()
                .build();

    }

    public ArrayList<String> getCheckedItems() {

        ArrayList<String> mTempArry = new ArrayList<String>();

        for(int i = 0; i < mList.size(); i++) {

            if (mSparseBooleanArray.get(i)) {
                mTempArry.add(mList.get(i));
            }
        }

        return mTempArry;
    }


    @Override
    public int getCount() {
        return mList.size();
    }

    @Override
    public Object getItem(int position) {
        return null;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {

        final ImageHolder imageHolder;

        if(convertView == null) {

            convertView = mInflater.inflate(R.layout.item_photo, null);

            imageHolder = new ImageHolder();
            imageHolder.imvPhoto = (ImageView) convertView.findViewById(R.id.imv_photo);
            imageHolder.imvCheckBox = (ImageView) convertView.findViewById(R.id.chk_box);

            convertView.setTag(imageHolder);

        } else {

            imageHolder = (ImageHolder) convertView.getTag();
        }


        imageLoader.displayImage("file://" + mList.get(position), imageHolder.imvPhoto, options, new SimpleImageLoadingListener() {
            @Override
            public void onLoadingComplete(Bitmap loadedImage) {
//                Animation anim = AnimationUtils.loadAnimation(mContext, R.anim.fade_in);
//                imageHolder.imvPhoto.setAnimation(anim);
//                anim.start();
            }
        });

        imageHolder.imvCheckBox.setSelected(mSparseBooleanArray.get(position));

        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (imageHolder.imvCheckBox.isSelected()) {
                    imageHolder.imvCheckBox.setSelected(!imageHolder.imvCheckBox.isSelected());
                    mSparseBooleanArray.put(position, imageHolder.imvCheckBox.isSelected());
                } else {

                    int selectedCount = getCheckedItems().size();

                    if (mContext instanceof  SelectImageActivity)
                        selectedCount += ((SelectImageActivity) mContext)._existCount;

                    if (selectedCount >= Constants.MAX_IMAGE_COUNT) {
                        mContext.showAlertDialog(mContext.getString(R.string.max_image_count_9));
                    } else {
                        imageHolder.imvCheckBox.setSelected(!imageHolder.imvCheckBox.isSelected());
                        mSparseBooleanArray.put(position, imageHolder.imvCheckBox.isSelected());
                    }
                }

                if (mContext instanceof SelectImageActivity)
                    ((SelectImageActivity) mContext).displayCount();
            }
        });

        return convertView;
    }


    public class ImageHolder {

        public ImageView imvPhoto;
        public ImageView imvCheckBox;
    }

}
