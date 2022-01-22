package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;

import java.util.ArrayList;

/**
 * Created by Asaf on 1/19/2016.
 */

public class UserInfoImageAdapter extends RecyclerView.Adapter<UserInfoImageAdapter.ImageHolder> {

    private ArrayList<String> _imageUrls = new ArrayList<>();
    private Context _context;

    public UserInfoImageAdapter(Context context) {

        this._context = context;
    }



    @Override
    public ImageHolder onCreateViewHolder(ViewGroup viewGroup, final int position) {

        View view = LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.item_userinfo_image, viewGroup, false);

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
