/*
 *  Copyright 2015 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

package org.appspot.apprtc;

import android.app.Activity;
import android.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.SeekBar;
import android.widget.TextView;


import com.julyseven.wonbridge.R;

import org.webrtc.RendererCommon.ScalingType;

/**
 * Fragment for call control.
 */
public class CallFragment extends Fragment {

  private View controlView;
  private TextView contactView;
  private ImageButton disconnectButton;
  private ImageButton cameraSwitchButton;
  private ImageButton cameraOnOffButton;
//  private ImageButton videoScalingButton;
  private ImageButton toggleMuteButton;
    private ImageButton toggleSpeakerButton;
  private TextView captureFormatText;
  private SeekBar captureFormatSlider;
  private OnCallEvents callEvents;
  private ScalingType scalingType;
  private boolean videoCallEnabled = true;
    private boolean isSender = false;

  private TextView ui_txvCallingState;

  /**
   * Call control interface for container activity.
   */
  public interface OnCallEvents {
    void onCallHangUp();
    void onCameraSwitch();
    void onVideoScalingSwitch(ScalingType scalingType);
    void onCaptureFormatChange(int width, int height, int framerate);
    boolean onToggleMic();
    boolean onToggleSpeaker();
    boolean onToggleCamera();
  }

  @Override
  public View onCreateView(LayoutInflater inflater, ViewGroup container,
      Bundle savedInstanceState) {

    controlView =
        inflater.inflate(R.layout.fragment_call, container, false);

    ui_txvCallingState = (TextView) controlView.findViewById(R.id.txv_calling_state);

    // Create UI controls.
    contactView =
        (TextView) controlView.findViewById(R.id.contact_name_call);
    disconnectButton =
        (ImageButton) controlView.findViewById(R.id.button_call_disconnect);
    cameraSwitchButton =
        (ImageButton) controlView.findViewById(R.id.button_call_switch_camera);

    cameraOnOffButton =
            (ImageButton) controlView.findViewById(R.id.button_camera_onoff);
//    videoScalingButton =
//        (ImageButton) controlView.findViewById(R.id.button_call_scaling_mode);
    toggleMuteButton =
        (ImageButton) controlView.findViewById(R.id.button_call_toggle_mic);
      toggleSpeakerButton =
              (ImageButton) controlView.findViewById(R.id.button_call_toggle_speaker);
    captureFormatText =
        (TextView) controlView.findViewById(R.id.capture_format_text_call);
    captureFormatSlider =
        (SeekBar) controlView.findViewById(R.id.capture_format_slider_call);

    // Add buttons click events.
    disconnectButton.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        callEvents.onCallHangUp();
      }
    });

    cameraOnOffButton.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View v) {
        boolean enabled = callEvents.onToggleCamera();
        cameraOnOffButton.setSelected(!enabled);
      }
    });

    cameraSwitchButton.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        callEvents.onCameraSwitch();
      }
    });

//    videoScalingButton.setOnClickListener(new View.OnClickListener() {
//      @Override
//      public void onClick(View view) {
//        if (scalingType == ScalingType.SCALE_ASPECT_FILL) {
//          videoScalingButton.setBackgroundResource(
//              R.drawable.ic_action_full_screen);
//          scalingType = ScalingType.SCALE_ASPECT_FIT;
//        } else {
//          videoScalingButton.setBackgroundResource(
//              R.drawable.ic_action_return_from_full_screen);
//          scalingType = ScalingType.SCALE_ASPECT_FILL;
//        }
//        callEvents.onVideoScalingSwitch(scalingType);
//      }
//    });

    scalingType = ScalingType.SCALE_ASPECT_FILL;

    toggleMuteButton.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View view) {
        boolean enabled = callEvents.onToggleMic();
        toggleMuteButton.setSelected(!enabled);
      }
    });

      toggleSpeakerButton.setOnClickListener(new View.OnClickListener() {
          @Override
          public void onClick(View view) {
              boolean enabled = callEvents.onToggleSpeaker();
            toggleSpeakerButton.setSelected(!enabled);
          }
      });

    return controlView;
  }

  @Override
  public void onStart() {
    super.onStart();

    boolean captureSliderEnabled = false;
    Bundle args = getArguments();
    if (args != null) {
      String contactName = args.getString(CallActivity.EXTRA_USERNAME);
      contactView.setText(contactName);   // jis
      videoCallEnabled = args.getBoolean(CallActivity.EXTRA_VIDEO_CALL, true);
        isSender = args.getBoolean(CallActivity.EXTRA_ISSENDER, false);
      captureSliderEnabled = videoCallEnabled
          && args.getBoolean(CallActivity.EXTRA_VIDEO_CAPTUREQUALITYSLIDER_ENABLED, false);
    }
    if (!videoCallEnabled) {
      cameraSwitchButton.setVisibility(View.INVISIBLE);
      cameraOnOffButton.setVisibility(View.INVISIBLE);
    }
      if (isSender) {
          ui_txvCallingState.setVisibility(View.VISIBLE);
          ui_txvCallingState.setText(getString(R.string.waiting_response));
      } else {
          ui_txvCallingState.setVisibility(View.INVISIBLE);
      }

    if (captureSliderEnabled) {
      captureFormatSlider.setOnSeekBarChangeListener(
          new CaptureQualityController(captureFormatText, callEvents));
    } else {
      captureFormatText.setVisibility(View.GONE);
      captureFormatSlider.setVisibility(View.GONE);
    }
  }

  public void hideStatus() {

    if (ui_txvCallingState != null)
      ui_txvCallingState.setVisibility(View.INVISIBLE);
  }

  @Override
  public void onAttach(Activity activity) {
    super.onAttach(activity);
    callEvents = (OnCallEvents) activity;
  }

}
