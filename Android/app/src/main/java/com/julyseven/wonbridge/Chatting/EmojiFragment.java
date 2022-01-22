package com.julyseven.wonbridge.Chatting;


import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.GridView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.adapter.EmojiAdapter;
import com.julyseven.wonbridge.base.BaseFragment;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.EmojiEntity;

import java.util.ArrayList;

/**
 * Created by sss on 8/22/2016.
 */
public class EmojiFragment extends BaseFragment {

    final int PAGE_SIZE = 18;

    public static final int emoji_ids[] = {

            R.drawable.emoji_1, R.drawable.emoji_2, R.drawable.emoji_3, R.drawable.emoji_4, R.drawable.emoji_5,
            R.drawable.emoji_6, R.drawable.emoji_7, R.drawable.emoji_8, R.drawable.emoji_9, R.drawable.emoji_10,
            R.drawable.emoji_11, R.drawable.emoji_12, R.drawable.emoji_13, R.drawable.emoji_14, R.drawable.emoji_15,
            R.drawable.emoji_16, R.drawable.emoji_17, R.drawable.emoji_18, R.drawable.emoji_19, R.drawable.emoji_20,
    };
    public static final String EMOJI_PREFIX = "[emoji_";
    public static final String EMOJI_SUFFIX = "]";

    GroupChattingActivity _context;

    int _pageIndex = 0;
    ArrayList<EmojiEntity> _emojiIds = new ArrayList<>();

    private GridView ui_gridView;

    EmojiAdapter _adapter;

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        _context = (GroupChattingActivity) getActivity();

        _pageIndex = getArguments().getInt(Constants.KEY_EMOJI_PAGE);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_emoji, container, false);

        ui_gridView = (GridView) view.findViewById(R.id.grid_emoji);

        _adapter = new EmojiAdapter(_context);

        _emojiIds.clear();
        for (int i = _pageIndex * PAGE_SIZE; i < (_pageIndex + 1) * PAGE_SIZE; i++) {

            if (i >= emoji_ids.length)
                break;

            EmojiEntity one = new EmojiEntity(emoji_ids[i], EMOJI_PREFIX + i + "]");
            _emojiIds.add(one);
        }

        ui_gridView.setAdapter(_adapter);
        _adapter.setDatas(_emojiIds);

        ui_gridView.setOnItemClickListener(new AdapterView.OnItemClickListener() {
            @Override
            public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
                _context.sendEmoji(_emojiIds.get(position));
            }
        });

        return view;
    }
}
