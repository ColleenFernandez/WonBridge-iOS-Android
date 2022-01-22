package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.model.ServiceItemEntity;
import com.julyseven.wonbridge.service.ServiceFragment;

import java.util.ArrayList;

/**
 * Created by sss on 8/22/2016.
 */
public class ServiceSearchAdapter extends BaseAdapter {

    Context _context;
    ServiceFragment _fragment;
    private ArrayList<ServiceItemEntity> _items = new ArrayList<>();

    public ServiceSearchAdapter(Context context, ServiceFragment fragment) {

        super();
        this._context = context;
        this._fragment = fragment;

    }

    public void setDatas(ArrayList<ServiceItemEntity> datas) {
        _items = datas;
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return _items.size();
    }

    @Override
    public Object getItem(int position) {
        return _items.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup viewGroup) {

        ItemHolder itemHolder;

        if (convertView == null){

            LayoutInflater inflater = (LayoutInflater)_context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_search, viewGroup, false);

            itemHolder = new ItemHolder();

            itemHolder.imvPhoto = (ImageView)convertView.findViewById(R.id.imv_image);
            itemHolder.txvName = (TextView)convertView.findViewById(R.id.txv_name);

            convertView.setTag(itemHolder);

        }else {
            itemHolder = (ItemHolder)convertView.getTag();
        }

        final ServiceItemEntity item = _items.get(position);

        Glide.with(_context).load(item.get_imageUrl()).into(itemHolder.imvPhoto);
        itemHolder.txvName.setText(item.get_name());

        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                _fragment.gotoServiceDetail(item.get_id());
            }
        });

        return convertView;
    }

    public class ItemHolder{

        public ImageView imvPhoto;
        public TextView txvName;
    }
}
