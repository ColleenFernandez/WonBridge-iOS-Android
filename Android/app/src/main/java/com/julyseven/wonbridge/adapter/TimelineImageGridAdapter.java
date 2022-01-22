package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.TimelineEntity;
import com.julyseven.wonbridge.timeline.TimelineDetailActivity;
import com.julyseven.wonbridge.timeline.TimelinePreviewActivity;

import java.util.ArrayList;

/**
 * Created by Asaf on 1/19/2016.
 */

public class TimelineImageGridAdapter extends RecyclerView.Adapter<TimelineImageGridAdapter.ImageHolder> {

    private ArrayList<String> _imageUrls = new ArrayList<>();
    private Context _context;
    private TimelineEntity _timeline;

    public TimelineImageGridAdapter(Context context, TimelineEntity timeline) {

        this._context = context;
        _timeline = timeline;
    }



    @Override
    public ImageHolder onCreateViewHolder(ViewGroup viewGroup, final int position) {

        View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_timeline_grid_image, viewGroup, false);

        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (_timeline.get_id() != 0) {
                    Intent intent = new Intent(_context, TimelineDetailActivity.class);
                    intent.putExtra(Constants.KEY_TIMELINE, _timeline);
                    _context.startActivity(intent);
                } else {
                    Intent intent = new Intent(_context, TimelinePreviewActivity.class);
                    intent.putExtra(Constants.KEY_IMAGEPATH, _imageUrls);
                    _context.startActivity(intent);
                }
            }
        });

        ImageHolder viewHolder = new ImageHolder(view);
        return viewHolder;
    }


    public void setDatas(ArrayList<String> images) {
        _imageUrls = images;
        notifyDataSetChanged();
    }

    @Override
    public void onBindViewHolder(ImageHolder viewHolder, int i) {

        String imageUrl = _imageUrls.get(i);
        Glide.with(_context).load(imageUrl).placeholder(new ColorDrawable(0xff5f99fb)).into(viewHolder.imvPhoto);

    }

    @Override
    public int getItemCount() {
        return (null != _imageUrls ? _imageUrls.size() : 0);
    }


    public class ImageHolder extends RecyclerView.ViewHolder {

        ImageView imvPhoto;

        public ImageHolder(View view) {

            super(view);
            imvPhoto = (ImageView) view.findViewById(R.id.imv_image);
        }
    }


}
