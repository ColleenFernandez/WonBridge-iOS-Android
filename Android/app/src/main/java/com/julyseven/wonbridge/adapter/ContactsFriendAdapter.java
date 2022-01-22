package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.content.Intent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.FriendEntity;
import com.julyseven.wonbridge.timeline.UserProfileActivity;

import java.util.ArrayList;

/**
 * Created by sss on 8/24/2016.
 */
public class ContactsFriendAdapter extends BaseAdapter {

    private Context _context;

    private ArrayList<FriendEntity> _contactDatas = new ArrayList<>();
    private ArrayList<FriendEntity> _contactAllDatas = new ArrayList<>();

    private boolean _isSearch = false;

    public ContactsFriendAdapter(Context context){

        super();
        this._context = context;

    }

    public void set_isSearch(boolean _isSearch) {
        this._isSearch = _isSearch;
    }

    public void setContactData(ArrayList<FriendEntity> data) {

        _contactAllDatas = data;

        _contactDatas.clear();
        _contactDatas.addAll(_contactAllDatas);
        notifyDataSetChanged();
    }

    @Override
    public int getCount() {
        return _contactDatas.size();
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

        ContactHolder contactHolder;

        if (convertView == null) {

            contactHolder = new ContactHolder();

            LayoutInflater inflater = (LayoutInflater) _context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_contact_friend, viewGroup, false);

            contactHolder.imvPhoto = (ImageView) convertView.findViewById(R.id.imv_photo);
            contactHolder.txvName = (TextView) convertView.findViewById(R.id.txv_name);
            contactHolder.txvAdd = (TextView) convertView.findViewById(R.id.txv_add);

            convertView.setTag(contactHolder);

        } else {
            contactHolder = (ContactHolder) convertView.getTag();
        }


        final FriendEntity contact = _contactDatas.get(position);
        contactHolder.txvName.setText(contact.get_name());
        Glide.with(_context).load(contact.get_photoUrl()).placeholder(R.drawable.img_user).error(R.drawable.img_user).into(contactHolder.imvPhoto);


        if (_isSearch) {

            contactHolder.txvAdd.setVisibility(View.VISIBLE);
            if (contact.is_isFriend()) {
                contactHolder.txvAdd.setSelected(false);
                contactHolder.txvAdd.setText(_context.getString(R.string.already_added));
            } else {
                contactHolder.txvAdd.setSelected(true);
                contactHolder.txvAdd.setText(_context.getString(R.string.add));
            }
        } else {
            contactHolder.txvAdd.setVisibility(View.INVISIBLE);
        }

        convertView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Intent intent = new Intent(_context, UserProfileActivity.class);
                intent.putExtra(Constants.KEY_FRIEND, contact);
                _context.startActivity(intent);
            }
        });

        return convertView;

    }

    public void filter(String charText) {

        charText = charText.toLowerCase();

        _contactDatas.clear();

        if (charText.length() == 0) {
            _contactDatas.addAll(_contactAllDatas);

        } else {

            for (FriendEntity friendEntity : _contactAllDatas) {

                String value = friendEntity.get_name().toLowerCase();

                if (value.contains(charText)) {
                    _contactDatas.add(friendEntity);
                }
            }
        }
        notifyDataSetChanged();
    }

    public class ContactHolder{

        public ImageView imvPhoto;
        public TextView txvName;
        public TextView txvAdd;
    }



}
