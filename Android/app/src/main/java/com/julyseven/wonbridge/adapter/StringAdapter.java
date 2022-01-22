package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.model.CountryEntity;

import java.util.ArrayList;

/**
 * Created by sss on 8/24/2016.
 */
public class StringAdapter extends BaseAdapter {

    private CommonActivity _context;


    private ArrayList<String> _datas = new ArrayList<>();

    public StringAdapter(CommonActivity context){

        super();
        this._context = context;

    }

    public void setData(ArrayList<String> data) {

        _datas = data;
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return _datas.size();
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
    public View getView(int position, View convertView, ViewGroup viewGroup) {

        StringHolder stringHolder;

        if (convertView == null) {

            stringHolder = new StringHolder();

            LayoutInflater inflater = (LayoutInflater) _context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_string, viewGroup, false);

            stringHolder.txvString = (TextView) convertView.findViewById(R.id.txv_string);

            convertView.setTag(stringHolder);

        } else {
            stringHolder = (StringHolder) convertView.getTag();
        }

        stringHolder.txvString.setText(_datas.get(position));


        return convertView;

    }

    public class StringHolder {

        public TextView txvString;
    }



}
