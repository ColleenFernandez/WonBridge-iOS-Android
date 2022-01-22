package com.julyseven.wonbridge.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.model.EmojiEntity;

import java.util.ArrayList;

/**
 * Created by sss on 8/22/2016.
 */
public class EmojiAdapter extends BaseAdapter {

    Context _context;
    ArrayList<EmojiEntity> _emojiDatas = new ArrayList<>();

    public EmojiAdapter(Context context) {

        super();
        this._context = context;

    }

    public void setDatas(ArrayList<EmojiEntity> data) {

        _emojiDatas = data;
        notifyDataSetChanged();

    }

    @Override
    public int getCount() {
        return _emojiDatas.size();
    }

    @Override
    public Object getItem(int position) {
        return _emojiDatas.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup viewGroup) {

        EmojiHolder emojiHolder;

        if (convertView == null){

            LayoutInflater inflater = (LayoutInflater)_context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = inflater.inflate(R.layout.item_emoji, viewGroup, false);

            emojiHolder = new EmojiHolder();

            emojiHolder.imvEmoji = (ImageView)convertView.findViewById(R.id.imv_emoji);

            convertView.setTag(emojiHolder);

        }else {
            emojiHolder = (EmojiHolder)convertView.getTag();
        }

        EmojiEntity emojiEntity = _emojiDatas.get(position);

        emojiHolder.imvEmoji.setImageResource(emojiEntity.get_emojiId());


        return convertView;
    }

    public class EmojiHolder{

        public ImageView imvEmoji;
    }
}
