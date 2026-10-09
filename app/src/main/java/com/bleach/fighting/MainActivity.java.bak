package com.bleach.fighting;

import android.app.Activity;
import android.os.Bundle;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;

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

    public static class MainMenu extends View {
        private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);

        public MainMenu(Context context) {
            super(context);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);

            float w = getWidth();
            float h = getHeight();

            canvas.drawColor(Color.rgb(8, 8, 16));

            paint.setColor(Color.rgb(65, 8, 22));
            canvas.drawCircle(w * 0.2f, h * 0.35f, h * 0.4f, paint);

            paint.setColor(Color.rgb(25, 25, 38));
            canvas.drawCircle(w * 0.85f, h * 0.3f, h * 0.35f, paint);

            paint.setTextAlign(Paint.Align.CENTER);
            paint.setTypeface(android.graphics.Typeface.DEFAULT_BOLD);
            paint.setTextSize(72);
            paint.setColor(Color.WHITE);
            canvas.drawText("BLEACH", w / 2f, h * 0.25f, paint);

            paint.setTextSize(28);
            paint.setColor(Color.rgb(220, 35, 55));
            canvas.drawText("BLOOD FIGHT", w / 2f, h * 0.34f, paint);

            drawButton(canvas, w / 2f, h * 0.52f, "START");
            drawButton(canvas, w / 2f, h * 0.66f, "CHARACTERS");
            drawButton(canvas, w / 2f, h * 0.80f, "SETTINGS");
        }

        private void drawButton(Canvas canvas, float cx, float cy, String label) {
            float bw = 330;
            float bh = 62;

            RectF rect = new RectF(
                cx - bw / 2f, cy - bh / 2f,
                cx + bw / 2f, cy + bh / 2f
            );

            paint.setColor(Color.rgb(30, 30, 42));
            canvas.drawRoundRect(rect, 14, 14, paint);

            paint.setStyle(Paint.Style.STROKE);
            paint.setStrokeWidth(3);
            paint.setColor(Color.rgb(190, 25
        @Override
        public boolean onTouchEvent(MotionEvent event) {
            if (event.getAction() == MotionEvent.ACTION_UP) {
                float x = event.getX();
                float y = event.getY();
                float w = getWidth();
                float h = getHeight();

                if (x >= w / 2f - 165 && x <= w / 2f + 165
                        && y >= h * 0.52f - 31 && y <= h * 0.52f + 31) {
                    ((Activity) getContext()).setContentView(
                        new BattleView(getContext())
                    );
                }
            }
            return true;
        }
    }

    public static class BattleView extends View {
        private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);

        private float playerX = 180;
        private float playerY = 0;
        private float enemyX = 0;
        private float velocityY = 0;

        private boolean leftPressed;
        private boolean rightPressed;
        private boolean attacking;

        private int playerHealth = 100;
        private int enemyHealth = 100;

        private long attackEndTime = 0;
        private final float gravity = 1.2f;
        private final float jumpPower = -22f;

        public BattleView(Context context) {
            super(context);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);

            float w = getWidth();
            float h = getHeight();

            if (enemyX == 0) enemyX =
        @Override
        public boolean onTouchEvent(MotionEvent event) {
            float x = event.getX();
            float y = event.getY();
            float w = getWidth();
            float h = getHeight();

            boolean left = x >= 65 && x <= 145 && y >= h - 115;
            boolean right = x >= 155 && x <= 235 && y >= h - 115;
            boolean jump = x >= w - 260 && x <= w - 180 && y >= h - 115;
            boolean hit = x >= w - 145 && x <= w - 65 && y >= h - 115;

            if (event.getAction() == MotionEvent.ACTION_DOWN ||
                event.getAction() == MotionEvent.ACTION_MOVE) {

                leftPressed = left;
                rightPressed = right;

                if (jump && playerY >= h - 310) {
                    velocityY = jumpPower;
                }

                if (hit && !attacking && enemyHealth > 0) {
                    attacking = true;
                    attackEndTime = System.currentTimeMillis() + 250;

                    float distance = Math.abs((playerX + 65) - enemyX);
                    if (distance < 220) {
                        enemyHealth = Math.max(0, enemyHealth - 20);
                    }
                }

                invalidate();
                return true;
            }

            if (event.getAction() == MotionEvent.ACTION_UP ||
