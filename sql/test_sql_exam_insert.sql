-- ============================================================
-- 验证脚本：查询连续出现 3 次及以上的姓名（自连接解法）
-- 表：know_engine.test_sql_exam
-- 说明：数据按 id 连续插入，覆盖以下场景
--   张三  连续3次(id 1~3)  -> 应命中
--   李四  连续2次(id 4~5)  -> 不应命中
--   王五  仅1次(id 6)      -> 不应命中
--   张三  再出现连续2次(id 7~8) -> 被打断的新段，不足3次，不影响（张三已因第一段命中）
--   赵六  连续4次(id 9~12) -> 应命中，且验证 DISTINCT 去重
--   孙七  连续3次但中间被 id 15 打断 -> 段长2，不应命中
-- 预期最终查询结果：赵六、张三（倒序）
-- ============================================================

-- 0. 如需重复执行，先清空测试数据
-- DELETE FROM `test_sql_exam` WHERE `name` IN ('张三','李四','王五','赵六','孙七');

-- 1. 张三连续3次（命中场景：恰好3连）
INSERT INTO `test_sql_exam` (`name`) VALUES ('张三');
INSERT INTO `test_sql_exam` (`name`) VALUES ('张三');
INSERT INTO `test_sql_exam` (`name`) VALUES ('张三');

-- 2. 李四连续2次（干扰场景：不足3次）
INSERT INTO `test_sql_exam` (`name`) VALUES ('李四');
INSERT INTO `test_sql_exam` (`name`) VALUES ('李四');

-- 3. 王五1次（干扰场景：打断上下文）
INSERT INTO `test_sql_exam` (`name`) VALUES ('王五');

-- 4. 张三再连续2次（干扰场景：同名但不连续满3次）
INSERT INTO `test_sql_exam` (`name`) VALUES ('张三');
INSERT INTO `test_sql_exam` (`name`) VALUES ('张三');

-- 5. 赵六连续4次（命中场景：超过3次，验证 DISTINCT 去重）
INSERT INTO `test_sql_exam` (`name`) VALUES ('赵六');
INSERT INTO `test_sql_exam` (`name`) VALUES ('赵六');
INSERT INTO `test_sql_exam` (`name`) VALUES ('赵六');
INSERT INTO `test_sql_exam` (`name`) VALUES ('赵六');

-- 6. 孙七"3次但中间被打断"（干扰场景：2+1，总数3但不连续）
INSERT INTO `test_sql_exam` (`name`) VALUES ('孙七');
INSERT INTO `test_sql_exam` (`name`) VALUES ('孙七');
INSERT INTO `test_sql_exam` (`name`) VALUES ('王五');  -- 插入打断行
INSERT INTO `test_sql_exam` (`name`) VALUES ('孙七');

-- ============================================================
-- 查看数据
SELECT `id`, `name` FROM `test_sql_exam` ORDER BY `id`;

-- 执行题解 SQL
SELECT DISTINCT a.`name` AS `name`
FROM `test_sql_exam` a
JOIN `test_sql_exam` b ON b.`id` = a.`id` + 1
JOIN `test_sql_exam` c ON c.`id` = b.`id` + 1
WHERE a.`name` = b.`name`
  AND b.`name` = c.`name`
ORDER BY `name` DESC;

-- 预期结果：
-- +--------+
-- | name   |
-- +--------+
-- | 赵六   |
-- | 张三   |
-- +--------+
-- 注意：utf8mb4_0900_ai_ci 按拼音排序，zhao > zhang，故 DESC 后赵六在前。
-- 若结果顺序不同，是排序规则(拼音序)导致的差异，不代表 SQL 有误。

-- ============================================================
-- 验证完成后清理（按 name 删除本次测试数据，不影响他人数据）
-- DELETE FROM `test_sql_exam` WHERE `name` IN ('张三','李四','王五','赵六','孙七');
