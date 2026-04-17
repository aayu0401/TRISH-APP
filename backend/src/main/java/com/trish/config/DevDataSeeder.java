package com.trish.config;

import com.trish.model.Gift;
import com.trish.model.Match;
import com.trish.model.Message;
import com.trish.model.Photo;
import com.trish.model.User;
import com.trish.model.Wallet;
import com.trish.repository.GiftRepository;
import com.trish.repository.MatchRepository;
import com.trish.repository.MessageRepository;
import com.trish.repository.UserRepository;
import com.trish.service.WalletService;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Component
@Profile("dev")
public class DevDataSeeder implements ApplicationRunner {

    private static final String DEMO_PASSWORD = "DemoPass123!";

    private final UserRepository userRepository;
    private final GiftRepository giftRepository;
    private final MatchRepository matchRepository;
    private final MessageRepository messageRepository;
    private final WalletService walletService;
    private final PasswordEncoder passwordEncoder;

    public DevDataSeeder(
            UserRepository userRepository,
            GiftRepository giftRepository,
            MatchRepository matchRepository,
            MessageRepository messageRepository,
            WalletService walletService,
            PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.giftRepository = giftRepository;
        this.matchRepository = matchRepository;
        this.messageRepository = messageRepository;
        this.walletService = walletService;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) {
        seedUsersAndDemoMatch();
        seedGiftCatalog();
    }

    private void seedUsersAndDemoMatch() {
        if (userRepository.count() >= 12 && userRepository.existsByEmail("demo@trish.app")) {
            return;
        }

        double baseLat = 40.7128;
        double baseLon = -74.0060;

        User demo = createUserIfMissing(
                "demo@trish.app",
                "Demo",
                User.Gender.FEMALE,
                LocalDate.of(1998, 6, 12),
                baseLat,
                baseLon,
                "Here for good vibes and great conversations.",
                "New York",
                "USA",
                true,
                true,
                List.of("Coffee", "Art", "Music"),
                "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=900"
        );

        User mia = createUserIfMissing(
                "mia@trish.app",
                "Mia",
                User.Gender.FEMALE,
                LocalDate.of(1999, 2, 5),
                baseLat + 0.015,
                baseLon + 0.01,
                "Weekend hikes, city nights.",
                "Brooklyn",
                "USA",
                true,
                true,
                List.of("Hiking", "Sushi", "Photography"),
                "https://images.unsplash.com/photo-1544723795-3fb6469f5b39?w=900"
        );

        createUserIfMissing(
                "arjun@trish.app",
                "Arjun",
                User.Gender.MALE,
                LocalDate.of(1997, 11, 20),
                baseLat - 0.01,
                baseLon + 0.02,
                "Builder by day, foodie by night.",
                "Jersey City",
                "USA",
                false,
                true,
                List.of("Street food", "Tech", "Gym"),
                "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=900"
        );

        createUserIfMissing(
                "sam@trish.app",
                "Sam",
                User.Gender.NON_BINARY,
                LocalDate.of(2000, 4, 3),
                baseLat + 0.008,
                baseLon - 0.014,
                "Curious soul. Big on kindness.",
                "Queens",
                "USA",
                false,
                true,
                List.of("Books", "Films", "Travel"),
                "https://images.unsplash.com/photo-1520975958225-3f61d68f5fdc?w=900"
        );

        createUserIfMissing(
                "lucas@trish.app",
                "Lucas",
                User.Gender.MALE,
                LocalDate.of(1996, 9, 14),
                baseLat - 0.02,
                baseLon - 0.01,
                "Let’s find a new favorite spot in the city.",
                "Manhattan",
                "USA",
                true,
                true,
                List.of("Running", "Jazz", "Brunch"),
                "https://images.unsplash.com/photo-1520975720828-1b6d61b6c995?w=900"
        );

        createUserIfMissing(
                "aisha@trish.app",
                "Aisha",
                User.Gender.FEMALE,
                LocalDate.of(1995, 12, 8),
                baseLat + 0.02,
                baseLon - 0.02,
                "Design, dancing, and deep talks.",
                "Harlem",
                "USA",
                false,
                true,
                List.of("Design", "Dance", "Podcasts"),
                "https://images.unsplash.com/photo-1524503033411-f6e7a7f0b7f4?w=900"
        );

        // Seed one ready-to-open match + a welcome message so Matches/Chat aren’t empty on first run.
        matchRepository.findMatchBetweenUsers(demo.getId(), mia.getId()).orElseGet(() -> {
            Match match = new Match();
            match.setUser1(demo);
            match.setUser2(mia);
            match.setCompatibilityScore(0.92);
            match.setIsActive(true);
            match.setIsBlindDateMatch(false);
            match.setRevealProgress(100);
            Match saved = matchRepository.save(match);

            if (messageRepository.findByMatchIdOrderBySentAt(saved.getId()).isEmpty()) {
                Message message = new Message();
                message.setMatch(saved);
                message.setSender(mia);
                message.setReceiver(demo);
                message.setContent("Hey Demo! Welcome to TRISH — want to grab coffee this weekend?");
                message.setIsRead(false);
                messageRepository.save(message);
            }

            return saved;
        });

        seedWalletCredits(demo, mia);
    }

    private void seedGiftCatalog() {
        if (giftRepository.count() > 0) {
            return;
        }

        List<Gift> gifts = new ArrayList<>();

        gifts.add(buildGift(
                "Rose Bouquet",
                "A classic bouquet to make their day.",
                149.0,
                "https://images.unsplash.com/photo-1519378058457-4c29a0a2efac?w=900",
                Gift.GiftCategory.FLOWERS,
                Gift.GiftType.PHYSICAL
        ));

        gifts.add(buildGift(
                "Chocolate Box",
                "Premium assorted chocolates.",
                199.0,
                "https://images.unsplash.com/photo-1541592106381-b31e9677c0e5?w=900",
                Gift.GiftCategory.CHOCOLATES,
                Gift.GiftType.PHYSICAL
        ));

        gifts.add(buildGift(
                "Virtual Heart",
                "Send a sweet virtual surprise.",
                49.0,
                "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=900",
                Gift.GiftCategory.VIRTUAL,
                Gift.GiftType.VIRTUAL
        ));

        gifts.add(buildGift(
                "Perfume Sample Set",
                "A curated set of iconic scents.",
                299.0,
                "https://images.unsplash.com/photo-1541643600914-78b084683601?w=900",
                Gift.GiftCategory.PERFUME,
                Gift.GiftType.PHYSICAL
        ));

        gifts.add(buildGift(
                "Minimal Necklace",
                "A simple piece that goes with everything.",
                399.0,
                "https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?w=900",
                Gift.GiftCategory.JEWELRY,
                Gift.GiftType.PHYSICAL
        ));

        giftRepository.saveAll(gifts);
    }

    private Gift buildGift(
            String name,
            String description,
            Double price,
            String imageUrl,
            Gift.GiftCategory category,
            Gift.GiftType type) {
        Gift gift = new Gift();
        gift.setName(name);
        gift.setDescription(description);
        gift.setPrice(price);
        gift.setImageUrl(imageUrl);
        gift.setCategory(category);
        gift.setType(type);
        gift.setIsAvailable(true);
        gift.setStockQuantity(100);
        gift.setPopularityScore(0);
        return gift;
    }

    private void seedWalletCredits(User... users) {
        double initialCredit = 2000.0;
        for (User user : users) {
            if (user == null) continue;
            Wallet wallet = walletService.getOrCreateWallet(user);
            double current = wallet.getBalance() != null ? wallet.getBalance() : 0.0;
            if (current >= initialCredit) continue;

            walletService.addToWallet(user, initialCredit - current, "Dev seed credit");
        }
    }

    private User createUserIfMissing(
            String email,
            String name,
            User.Gender gender,
            LocalDate dateOfBirth,
            Double latitude,
            Double longitude,
            String bio,
            String city,
            String country,
            boolean isPremium,
            boolean emailVerified,
            List<String> interests,
            String photoUrl) {
        return userRepository.findByEmail(email).orElseGet(() -> {
            User user = new User();
            user.setEmail(email);
            user.setPassword(passwordEncoder.encode(DEMO_PASSWORD));
            user.setName(name);
            user.setDateOfBirth(dateOfBirth);
            user.setGender(gender);
            user.setIsActive(true);
            user.setIsPremium(isPremium);
            user.setIsVerified(false);
            user.setEmailVerified(emailVerified);
            user.setMinAge(18);
            user.setMaxAge(100);
            user.setMaxDistance(50);
            user.setLatitude(latitude);
            user.setLongitude(longitude);
            user.setBio(bio);
            user.setCity(city);
            user.setCountry(country);
            user.setInterests(new ArrayList<>(interests != null ? interests : List.of()));

            if (photoUrl != null && !photoUrl.isBlank()) {
                Photo photo = new Photo();
                photo.setUser(user);
                photo.setUrl(photoUrl);
                photo.setDisplayOrder(0);
                user.getPhotos().add(photo);
            }

            return userRepository.save(user);
        });
    }
}
