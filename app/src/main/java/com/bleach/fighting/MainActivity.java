package com.bleach.fighting;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.content.Context;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(
                WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN
        );

        setContentView(new MainMenu(this));
    }

    // =========================
    // MAIN MENU
    // =========================

    public static class MainMenu extends View {

        private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);

        public MainMenu(Context context) {
            super(context);
            paint.setTypeface(android.graphics.Typeface.DEFAULT_BOLD);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            float w = getWidth();
            float h = getHeight();

            // Background
            canvas.drawColor(Color.rgb(7, 7, 12));

            // Dark red atmosphere
            paint.setColor(Color.rgb(45, 8, 15));
            canvas.drawCircle(w * 0.18f, h * 0.35f, h * 0.45f, paint);

            paint.setColor(Color.rgb(20, 20, 30));
