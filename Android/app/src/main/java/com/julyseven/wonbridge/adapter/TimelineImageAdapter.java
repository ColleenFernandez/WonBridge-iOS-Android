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
import com.julyseven.wonbridge.Chatting.ImagePreviewActivity;
import com.julyseven.wonbridge.timeline.TimelinePreviewActivity;

import java.util.ArrayList;

/**
 * Created by Asaf on 1/19/2016.
 */

public class TimelineImageAdapter extends RecyclerView.Adapter<TimelineImageAdapter.ImageHolder> {

    private ArrayList<String> _imageUrls = new ArrayList<>();
    private Context _context;
    private RecyclerView _recycler;

    public TimelineImageAdapter(Context context, RecyclerView recyclerView) {

        this._context = context;
        this._recycler = recyclerView;
    }



    @Override
    public ImageHolder onCreateViewHolder(ViewGroup viewGroup, final int position) {

        View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_timeline_image, viewGroup, false);
        view.setOnClickListener(new ImageOnClickListener());

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

    class ImageOnClickListener implements View.OnClickListener {
        @Override
        public void onClick(View v) {
            int itemPosition = _recycler.getChildAdapterPosition(v);
            String imageUrl = _imageUrls.get(itemPosition);

            Intent intent = new Intent(_context, TimelinePreviewActivity.class);
            intent.putExtra(Constants.KEY_IMAGEPATH, _imageUrls);
            _context.startActivity(intent);

        }
    }
}

