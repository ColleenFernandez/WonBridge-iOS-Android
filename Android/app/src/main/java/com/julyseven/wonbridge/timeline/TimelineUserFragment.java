package com.julyseven.wonbridge.timeline;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.adapter.TimelineUserAdapter;
import com.julyseven.wonbridge.base.BaseFragment;
import com.julyseven.wonbridge.commons.Commons;
import com.julyseven.wonbridge.model.UserEntity;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayout;
import com.orangegangsters.github.swipyrefreshlayout.library.SwipyRefreshLayoutDirection;

/**
 * Created by sss on 8/22/2016.
 */
public class TimelineUserFragment extends BaseFragment {

    TimelineActivity _context;

    UserEntity _user;

    ListView ui_lstUser;
    private TimelineUserAdapter _adapter;
    SwipyRefreshLayout ui_refreshLayout;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        _context = (TimelineActivity) getActivity();

        _user = Commons.g_user;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View view = inflater.inflate(R.layout.fragment_userlist, container, false);

        ui_lstUser = (ListView) view.findViewById(R.id.lst_user);

        ui_refreshLayout = (SwipyRefreshLayout) view.findViewById(R.id.refresh);

        ui_refreshLayout.setOnRefreshListener(new SwipyRefreshLayout.OnRefreshListener() {
            @Override
            public void onRefresh(SwipyRefreshLayoutDirection direction) {
                if (direction == SwipyRefreshLayoutDirection.TOP) {
                    _context.getNearbyUsers(true);
                } else if (direction == SwipyRefreshLayoutDirection.BOTTOM) {
                    _context.getNearbyUsers(false);
                }
            }
        });

        _adapter = new TimelineUserAdapter(_context);
        ui_lstUser.setAdapter(_adapter);
        _adapter.setDatas(_context._nearbyUsers);

        return view;
    }


    public void refresh() {

        if (_context != null && isAdded())
            _adapter.setDatas(_context._nearbyUsers);
    }


    @Override
    public void onResume() {
        super.onResume();

    }
}
