package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.graphics.Bitmap;
import android.support.v4.view.PagerAdapter;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.animation.GlideAnimation;
import com.bumptech.glide.request.target.SimpleTarget;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.utils.TouchImageView;

import java.util.ArrayList;

/**
 * Created by JIS on 10/18/2016.
 */

public class TimelinePreviewAdapter extends PagerAdapter {

    Context _context;
    LayoutInflater _layoutInflator;
    ArrayList<String> _imageUrls = new ArrayList<>();

    public TimelinePreviewAdapter(Context context) {
        _context = context;
        _layoutInflator = (LayoutInflater) _context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    public void setDatas(ArrayList<String> datas) {
        _imageUrls = datas;
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return _imageUrls.size();
    }

    @Override
    public boolean isViewFromObject(View view, Object object) {
        return view == ((LinearLayout) object);
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position) {

        View itemView = _layoutInflator.inflate(R.layout.timeline_preview_item, container, false);

        final TouchImageView imageView = (TouchImageView) itemView.findViewById(R.id.imv_preview);
        Glide.with(_context).load(_imageUrls.get(position)).asBitmap().into(new SimpleTarget<Bitmap>() {
            @Override
            public void onResourceReady(Bitmap resource, GlideAnimation<? super Bitmap> glideAnimation) {
                imageView.setImageBitmap(resource);
            }
        });

        container.addView(itemView);

        return itemView;
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        container.removeView((LinearLayout) object);
    }
}
