package com.trish.service;

import com.trish.model.ProfileView;
import com.trish.model.User;
import com.trish.repository.ProfileViewRepository;
import com.trish.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class ProfileViewService {

    @Autowired
    private ProfileViewRepository profileViewRepository;

    @Autowired
    private UserRepository userRepository;

    /**
     * Record that viewerId viewed profile of viewedUserId
     */
    @Transactional
    public void recordView(Long viewerId, Long viewedUserId) {
        if (viewerId.equals(viewedUserId)) return;

        User viewer = userRepository.findById(viewerId)
                .orElseThrow(() -> new IllegalArgumentException("Viewer not found"));
        User viewedUser = userRepository.findById(viewedUserId)
                .orElseThrow(() -> new IllegalArgumentException("Viewed user not found"));

        ProfileView pv = new ProfileView();
        pv.setViewer(viewer);
        pv.setViewedUser(viewedUser);
        profileViewRepository.save(pv);
    }

    /**
     * Get users who viewed current user's profile (unique, most recent first)
     */
    public List<User> getWhoViewedMe(Long userId, int page, int size) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Pageable pageable = PageRequest.of(0, 100);
        List<ProfileView> views = profileViewRepository.findByViewedUserOrderByViewedAtDesc(user, pageable).getContent();

        Set<Long> seen = new LinkedHashSet<>();
        List<User> uniqueViewers = views.stream()
                .map(ProfileView::getViewer)
                .filter(v -> seen.add(v.getId()))
                .collect(Collectors.toList());

        int from = page * size;
        int to = Math.min(from + size, uniqueViewers.size());
        return from < uniqueViewers.size() ? uniqueViewers.subList(from, to) : List.of();
    }

    /**
     * Get count of unique profile viewers
     */
    public long getViewCount(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));
        return profileViewRepository.countUniqueViewers(user);
    }
}
