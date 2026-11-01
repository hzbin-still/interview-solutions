package concurrency;

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;

/**
 * 打印奇数的线程（原题误命名为 OldThread，实为 Odd）
 */
public class OddThread implements Runnable {
    private final Lock lock;
    private final Condition condition;
    private final int maxCount;

    public OddThread(Lock lock, Condition condition, int maxCount) {
        this.lock = lock;
        this.condition = condition;
        this.maxCount = maxCount;
    }

    @Override
    public void run() {
        // await/signal 必须由持有锁的线程调用，所以先 lock()
        lock.lock();
        try {
            for (int i = 1; i <= maxCount; i += 2) {
                // 用 while 而不是 if：防虚假唤醒 + 唤醒后需重抢锁，条件可能已再次变化
                while (!Main.turn) {
                    try {
                        condition.await();
                    } catch (InterruptedException e) {
                        // 恢复中断标志后退出，不吞掉中断
                        Thread.currentThread().interrupt();
                        return;
                    }
                }
                System.out.println("OddThread: " + i);
                Main.turn = false;      // 切换到偶数线程
                condition.signalAll();  // 唤醒共享队列上的等待者
            }
        } finally {
            // 必须放 finally：异常时也要释放锁，否则其他线程永久阻塞在 lock()
            lock.unlock();
        }
    }
}
