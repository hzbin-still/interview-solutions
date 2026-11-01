package concurrency;

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

/**
 * 面试题：两个线程交替打印奇偶数（1~maxCount）
 * 共享三件套：一把 Lock（互斥）、一个 Condition（同一等待队列）、一个标志位（轮到谁）
 *
 * 运行方式（无需 Maven，在项目根目录）：
 *   javac -encoding UTF-8 -d out src/concurrency/*.java
 *   java -cp out concurrency.Main
 */
public class Main {
    /** true = 轮到奇数线程，false = 轮到偶数线程（读写均在 lock 临界区内，可见性由锁保证） */
    static boolean turn = true;

    public static void main(String[] args) {
        ReentrantLock lock = new ReentrantLock();
        // Condition 必须只创建一次并共享：各自 newCondition() 会产生独立等待队列导致死锁
        Condition condition = lock.newCondition();
        new Thread(new OddThread(lock, condition, 100)).start();
        new Thread(new EvenThread(lock, condition, 100)).start();
    }
}
