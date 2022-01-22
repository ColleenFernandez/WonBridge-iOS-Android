package com.julyseven.wonbridge.adapter;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.timeline.WriteTimelineActivity;

import java.util.ArrayList;

/**
 * Created by Asaf on 1/19/2016.
 */

public class TimelineImageEditAdapter extends RecyclerView.Adapter<TimelineImageEditAdapter.ImageHolder> {

    private ArrayList<String> _imageUrls = new ArrayList<>();
    private WriteTimelineActivity _context;

    public TimelineImageEditAdapter(WriteTimelineActivity context) {

        this._context = context;
    }


    @Override
    public ImageHolder onCreateViewHolder(ViewGroup viewGroup, final int position) {

        View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_timeline_image_edit, viewGroup, false);

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
        Bitmap bitmap = BitmapFactory.decodeFile(imageUrl);
//        Bitmap scaledBitmap = BitmapUtils.getSizeLimitedBitmap(bitmap);
//        bitmap.recycle();
        viewHolder.imvPhoto.setImageBitmap(bitmap);

        final int position = i;

        viewHolder.imvDelete.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                _context.removeImage(_imageUrls.get(position));
                notifyDataSetChanged();
            }
        });
    }

    @Override
    public int getItemCount() {
        return (null != _imageUrls ? _imageUrls.size() : 0);
    }


    public class ImageHolder extends RecyclerView.ViewHolder {

        ImageView imvPhoto;
        ImageView imvDelete;

        public ImageHolder(View view) {

            super(view);
            imvPhoto = (ImageView) view.findViewById(R.id.imv_image);
            imvDelete = (ImageView) view.findViewById(R.id.imv_delete);
        }
    }


}
