package com.julyseven.wonbridge.adapter;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;

import java.util.ArrayList;
import java.util.Arrays;

import se.emilsjolander.stickylistheaders.StickyListHeadersAdapter;

public class VillageAdapter extends BaseAdapter implements StickyListHeadersAdapter {

    CommonActivity _context;

    private ArrayList<String> _cities = new ArrayList<>();
    private ArrayList<String> _provinces = new ArrayList<>();
    private String[][] _cityArray;
    private LayoutInflater inflater;

    public VillageAdapter(CommonActivity context) {

        _context = context;
        inflater = LayoutInflater.from(context);
    }

    public void setData(String[] provinces, String[][] cities) {

        _provinces = new ArrayList<>(Arrays.asList(provinces));

        _cityArray = cities;

        for (int i = 0; i < cities.length; i++) {
            _cities.addAll(new ArrayList<>(Arrays.asList(cities[i])));
        }
    }

    @Override
    public int getCount() {
        return _cities.size();
    }

    @Override
    public Object getItem(int position) {
        return _cities.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        ViewHolder holder;

        if (convertView == null) {
            holder = new ViewHolder();
            convertView = inflater.inflate(R.layout.item_string, parent, false);
            holder.text = (TextView) convertView.findViewById(R.id.txv_string);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        holder.text.setText(_cities.get(position));

        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent();
                intent.putExtra(Constants.KEY_VILLAGE, _provinces.get((int) getHeaderId(position)) + " " + _cities.get(position));
                _context.setResult(Activity.RESULT_OK, intent);
                _context.finish();
            }
        });

        return convertView;
    }

    @Override
    public View getHeaderView(int position, View convertView, ViewGroup parent) {

        HeaderViewHolder holder;
        if (convertView == null) {
            holder = new HeaderViewHolder();
            convertView = inflater.inflate(R.layout.item_header_string, parent, false);
            holder.text = (TextView) convertView.findViewById(R.id.txv_string);
            convertView.setTag(holder);
        } else {
            holder = (HeaderViewHolder) convertView.getTag();
        }
        //set header text as first char in name
        String headerText = "" + _provinces.get((int)getHeaderId(position));
        holder.text.setText(headerText);
        return convertView;
    }

    @Override
    public long getHeaderId(int position) {

        for (int i = 0; i < _cityArray.length; i++) {

            for (int j = 0; j < _cityArray[i].length; j++) {

                if (_cityArray[i][j].equals(_cities.get(position)))
                    return i;
            }
        }

        return -1;
    }

    class HeaderViewHolder {
        TextView text;
    }

    class ViewHolder {
        TextView text;
    }

}