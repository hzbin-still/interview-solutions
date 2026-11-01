package concurrency;

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;

/**
 * 打印偶数的线程，与 OddThread 逻辑镜像
 */
public class EvenThread implements Runnable {
    private final Lock lock;
    private final Condition condition;
    private final int maxCount;

    public EvenThread(Lock lock, Condition condition, int maxCount) {
        this.lock = lock;
        this.condition = condition;
        this.maxCount = maxCount;
    }

    @Override
    public void run() {
        lock.lock();
        try {
            for (int i = 2; i <= maxCount; i += 2) {
                // 条件与 OddThread 相反：turn 为 true 时未轮到自己，等待
                while (Main.turn) {
                    try {
                        condition.await();
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                        return;
                    }
                }
                System.out.println("EvenThread: " + i);
                Main.turn = true;       // 切换回奇数线程
                condition.signalAll();
            }
        } finally {
            lock.unlock();
        }
    }
}
