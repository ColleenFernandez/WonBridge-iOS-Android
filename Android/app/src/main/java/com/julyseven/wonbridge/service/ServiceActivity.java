package com.julyseven.wonbridge.service;

import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.widget.ImageView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonTabActivity;

import java.util.ArrayList;
import java.util.List;

public class ServiceActivity extends CommonTabActivity implements View.OnClickListener {

    TabLayout ui_tabLayout;
    ViewPager ui_viewPager;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_service);

        loadLayout();
    }

    @Override
    public void loadLayout() {

        super.loadLayout();

        ui_lytService.setBackgroundColor(0xff23262b);
        ui_txvService.setTextColor(getResources().getColor(R.color.colorWhiteBlue));
        ui_imvService.setImageResource(R.drawable.button_service_on);

        setUnRead();

        ui_viewPager = (ViewPager)findViewById(R.id.viewpager);
        setupViewPager(ui_viewPager);

        ui_tabLayout = (TabLayout)findViewById(R.id.tabs);
        ui_tabLayout.setupWithViewPager(ui_viewPager);

    }


    private void setupViewPager(ViewPager viewPager){

        ViewPagerAdapter adapter = new ViewPagerAdapter(getSupportFragmentManager());

        adapter.addFrag(new ServiceFragment(), getString(R.string.business_service));
        adapter.addFrag(new ChuGuoFragment(), getString(R.string.chuguo_qa));
        viewPager.setAdapter(adapter);
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()){

            case R.id.lyt_msg:
                gotoMessage();
                break;

            case R.id.lyt_mypage:
                gotoMyPage();
                break;

            case R.id.lyt_contact:
                gotoContact();
                break;

            case R.id.lyt_timeline:
                gotoTimeline();
                break;

        }

    }

    class ViewPagerAdapter extends FragmentPagerAdapter {

        private final List<Fragment> mFragmentList = new ArrayList<>();
        private final List<String> mFragmentTitleList = new ArrayList<>();

        public ViewPagerAdapter(FragmentManager manager) {
            super(manager);
        }

        @Override
        public Fragment getItem(int position) {
            return mFragmentList.get(position);
        }

        @Override
        public int getCount() {
            return mFragmentList.size();
        }

        public void addFrag(Fragment fragment, String title) {

            mFragmentList.add(fragment);
            mFragmentTitleList.add(title);
        }

        @Override
        public CharSequence getPageTitle(int position) {

            // return null to display only the icon
            return mFragmentTitleList.get(position);
        }
    }


}
