package com.julyseven.wonbridge.mypage;

/*
* Used for eventbus callback purposes
* */
public class WechatPayEvent {

    private boolean successful;
    private String _wechatId;

    public WechatPayEvent(boolean successful, String wechatId) {

        this.successful = successful;
        _wechatId = wechatId;
    }

    public boolean isSuccessful() {
        return successful;
    }

    public void setSuccessful(boolean successful) {
        this.successful = successful;
    }

    public String get_wechatId() {
        return _wechatId;
    }

    public void set_wechatId(String _wechatId) {
        this._wechatId = _wechatId;
    }
}
