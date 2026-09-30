package com.bleach.fighting;

import android.app.Activity;
import android.os.Bundle;
import android.graphics.Color;
import android.graphics.Canvas;
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

        setContentView(new BattleView(this));
    }

    public static class BattleView extends View {

        private final Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);

        private float playerX = 250;
        private float playerY = 0;
        private float velocityY = 0;

        private boolean leftPressed = false;
        private boolean rightPressed = false;

        private final float gravity = 1.2f;
        private final float jumpPower = -22f;

        public BattleView(android.content.Context context) {
            super(context);
            paint.setTypeface(android.graphics.Typeface.DEFAULT_BOLD);
        }

        @Override
        protected void onDraw(Canvas canvas) {
            super.onDraw(canvas);

            float w = getWidth();
            float h = getHeight();

            // الخلفية
            canvas.drawColor(Color.rgb(10, 10, 18));

            // أرضية القتال
            paint.setColor(Color.rgb(35, 35, 45));
            canvas.drawRect(0, h - 150, w, h, paint);

            // تحديث الحركة
            if (leftPressed) {
                playerX -= 8;
            }

            if (rightPressed) {
                playerX += 8;
            }

            velocityY += gravity;
            playerY += velocityY;

            float groundY = h - 150 - 140;

            if (playerY > groundY) {
                playerY = groundY;
                velocityY = 0;
            }

            // الشخصية المؤقتة
            drawPlayer(canvas, playerX, playerY);

            // واجهة الحياة
            drawHealthBar(canvas, 40, 35, 400, 28, 100);
            drawHealthBar(canvas, w - 440, 35, 400, 28, 100);

            // اسم الشخصية
            paint.setTextSize(28);
            paint.setColor(Color.WHITE);
            canvas.drawText("PLAYER", 40, 95, paint);
            canvas.drawText("ENEMY", w - 180, 95, paint);

            // أزرار التحكم
            drawButton(canvas, 80, h - 120, 80, 80, "←");
            drawButton(canvas, 180, h - 120, 80, 80, "→");
            drawButton(canvas, w - 280, h - 120, 80, 80, "J");
            drawButton(canvas, w - 170, h - 120, 80, 80, "⚔");
        }

        private void drawPlayer(Canvas canvas, float x, float y) {

            // جسم
            paint.setColor(Color.rgb(220, 220, 230));
            canvas.drawRect(x, y + 55, x + 70, y + 140, paint);

            // الرأس
            paint.setColor(Color.rgb(240, 200, 170));
            canvas.drawCircle(x + 35, y + 35, 32, paint);

            // الشعر
            paint.setColor(Color.BLACK);
            canvas.drawCircle(x + 35, y + 20, 30, paint);

            // السيف
            paint.setColor(Color.WHITE);
            canvas.drawRect(x + 68, y + 70, x + 150, y + 78, paint);

            paint.setColor(Color.rgb(120, 70, 30));
            canvas.drawRect(x + 55, y + 65, x + 75, y + 85, paint);
        }

        private void drawHealthBar(
                Canvas canvas,
                float x,
                float y,
                float width,
                float height,
                int health
        ) {
            paint.setColor(Color.DKGRAY);
            canvas.drawRect(x, y, x + width, y + height, paint);

            paint.setColor(Color.rgb(210, 35, 45));
            canvas.drawRect(
                    x,
                    y,
                    x + width * health / 100f,
                    y + height,
                    paint
            );
        }

        private void drawButton(
                Canvas canvas,
                float x,
                float y,
                float width,
                float height,
                String text
        ) {
            paint.setColor(Color.argb(180, 50, 50, 60));
            canvas.drawRoundRect(
                    new RectF(x, y, x + width, y + height),
                    20,
                    20,
                    paint
            );

            paint.setColor(Color.WHITE);
            paint.setTextSize(38);

            float textWidth = paint.measureText(text);

            canvas.drawText(
                    text,
                    x + (width - textWidth) / 2,
                    y + 53,
                    paint
            );
        }

        @Override
        public boolean onTouchEvent(MotionEvent event) {

            float x = event.getX();
            float y = event.getY();

            float h = getHeight();
            float w = getWidth();

            boolean left = x >= 80 && x <= 160 && y >= h - 120;
            boolean right = x >= 180 && x <= 260 && y >= h - 120;
            boolean jump = x >= w - 280 && x <= w - 200 && y >= h - 120;

            if (event.getAction() == MotionEvent.ACTION_DOWN ||
                event.getAction() == MotionEvent.ACTION_MOVE) {

                leftPressed = left;
                rightPressed = right;

                if (jump && playerY >= h - 310) {
                    velocityY = jumpPower;
                }

                invalidate();
                return true;
            }

            if (event.getAction() == MotionEvent.ACTION_UP) {
                leftPressed = false;
                rightPressed = false;
                invalidate();
                return true;
            }

            return true;
        }
    }
}
