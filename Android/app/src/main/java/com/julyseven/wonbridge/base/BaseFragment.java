package com.julyseven.wonbridge.base;


import android.support.v4.app.Fragment;

/**
 * Created by sss on 8/24/2016.
 */
public class BaseFragment extends Fragment {

    public BaseActivity _context;

    public void showProgress(){

        _context.showProgress();
    }

    public void CloseProgress(){

        _context.closeProgress();
    }

    public void showToast(String strMsg){

        _context.showToast(strMsg);
    }

    public void showAlert(String strMsg){

        _context.showAlertDialog(strMsg);
    }
}
