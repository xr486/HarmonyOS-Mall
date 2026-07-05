package com.hongmen.mall.scheduler;

import com.hongmen.mall.service.RecommendationService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class RecommendationScheduler {

    private static final Logger logger = LoggerFactory.getLogger(RecommendationScheduler.class);

    private final RecommendationService recommendationService;

    public RecommendationScheduler(RecommendationService recommendationService) {
        this.recommendationService = recommendationService;
    }

    @Scheduled(cron = "0 0 2 * * ?")
    public void scheduledRefreshRecommendations() {
        logger.info("Starting scheduled recommendation refresh...");
        try {
            recommendationService.refreshAllRecommendations();
            logger.info("Scheduled recommendation refresh completed successfully");
        } catch (Exception e) {
            logger.error("Scheduled recommendation refresh failed: {}", e.getMessage(), e);
        }
    }

    @Scheduled(cron = "0 */30 * * * ?")
    public void scheduledRefreshRecentUsers() {
        logger.info("Starting scheduled recommendation refresh for recent users...");
        try {
            recommendationService.refreshAllRecommendations();
            logger.info("Scheduled recommendation refresh for recent users completed");
        } catch (Exception e) {
            logger.error("Scheduled recommendation refresh for recent users failed: {}", e.getMessage(), e);
        }
    }
}