package com.julyseven.wonbridge.timeline;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.method.LinkMovementMethod;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.julyseven.wonbridge.R;
import com.julyseven.wonbridge.base.CommonActivity;
import com.julyseven.wonbridge.commons.Constants;
import com.julyseven.wonbridge.model.TimelineEntity;

public class TimelineAllTextActivity extends CommonActivity implements View.OnClickListener {

    private TimelineEntity _timeline;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_all_text);

        _timeline = (TimelineEntity) getIntent().getSerializableExtra(Constants.KEY_TIMELINE);
        
        loadLayout();
    }

    private void loadLayout() {

        TextView txvTitle = (TextView) findViewById(R.id.header_title);
        txvTitle.setText(getString(R.string.content_all));

        ImageView imvBack = (ImageView) findViewById(R.id.imv_back);
        imvBack.setOnClickListener(this);

        TextView txvContent = (TextView) findViewById(R.id.txv_content);
        txvContent.setText(_timeline.get_content());
        txvContent.setMovementMethod(LinkMovementMethod.getInstance());

        TextView txvLink = (TextView) findViewById(R.id.txv_link);
        if (_timeline.get_link().length() == 0) {
            txvLink.setVisibility(View.GONE);
        } else {
            txvLink.setVisibility(View.VISIBLE);
        }
        txvLink.setOnClickListener(this);

    }

    private void onLink() {

        String url = _timeline.get_link();
        if (!url.startsWith("http://") && !url.startsWith("https://"))
            url = "http://" + url;
        Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
        _context.startActivity(browserIntent);
    }


    private void onBack() {
        finish();
    }


    @Override
    public void onClick(View view) {

        switch (view.getId()) {

            case R.id.imv_back:
                onBack();
                break;

            case R.id.txv_link:
                onLink();
                break;

        }

    }


}
