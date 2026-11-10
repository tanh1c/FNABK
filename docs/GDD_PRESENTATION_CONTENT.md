# FNABK — GDD Presentation Content

Nội dung slide bằng tiếng Anh để thống nhất với GDD; lời thuyết trình bằng tiếng Việt. Đề xuất **15 slide, khoảng 12–15 phút** (chưa tính hỏi đáp); điều chỉnh thời lượng theo yêu cầu môn học. Phần “Trên slide” chỉ gồm tiêu đề và tối đa năm dòng, mỗi dòng tối đa năm từ. Lời nói và gợi ý hình không đưa nguyên lên slide. Tên nhóm và giảng viên đối chiếu từ bìa report; phân công người nói theo nhóm.

Nguồn thiết kế: [GDD hiện tại](GDD.md) và [report LaTeX](../FIVE_NIGHTS_AT_BÁCH_KHOA_CC02____GROUP_07/chapters/submission_gdd.tex). Đây là **thiết kế và kế hoạch**, không phải tuyên bố game đã hoàn thiện; các giá trị cân bằng cần kiểm thử.

---

## Slide 1 — Five Nights at Bách Khoa

**Trên slide**

> Five Nights at Bách Khoa  
> Survival Horror · Roblox  
> Game Programming · CO3045  
> CC02 · Group 07

**Minh họa:** Ảnh tổng quan [campus trong Studio](../FIVE_NIGHTS_AT_BÁCH_KHOA_CC02____GROUP_07/assets/campus_studio_overview.png), đặt làm ảnh bìa có lớp phủ tối nhẹ. Tên thành viên và giảng viên đưa vào chân trang hoặc lời giới thiệu, nếu quy định môn học yêu cầu.

**Lời thuyết trình:** “Xin chào thầy cô và các bạn. Nhóm 07 xin trình bày Game Design Document của *Five Nights at Bách Khoa*, một trò chơi sinh tồn kinh dị lấy cảm hứng từ môi trường đại học. Trong phần trình bày, nhóm sẽ giới thiệu trải nghiệm chơi, các hệ thống chính và kế hoạch phát triển.”

---

## Slide 2 — High Concept

**Trên slide**

> Post-apocalyptic university campus  
> Solo or four-player co-op  
> Survive five nights  
> Identify disguised threats  
> Signal for helicopter rescue

**Minh họa:** Ảnh campus kèm ba biểu tượng: căn cứ, Mimic và trực thăng. Có thể dùng hình khối đơn giản; không cần thêm chữ vào ảnh.

**Lời thuyết trình:** “Game diễn ra trong khuôn viên trường sau một thảm họa. Từ một đến bốn người chơi lựa chọn nơi trú ẩn, thu thập vật tư và sống sót qua năm đêm. Điểm tạo áp lực là Mimic có thể giả dạng người khác, trong khi mục tiêu cuối là phát tín hiệu và được trực thăng cứu.”

---

## Slide 3 — Setting & Inspiration

**Trên slide**

> Evacuation simulation goes wrong  
> Campus becomes quarantined  
> Five Nights: anticipation  
> Phasmophobia: investigation  
> Don't Starve: survival planning

**Minh họa:** Dải ba hình hoặc biểu tượng: phòng thí nghiệm → khuôn viên bị cô lập → tín hiệu cứu hộ. Các tên game tham khảo chỉ cần đặt bằng chữ; dùng ảnh chính thức nếu có quyền sử dụng và ghi nguồn.

**Lời thuyết trình:** “Cốt truyện bắt đầu từ một nghiên cứu mô phỏng ứng phó và sơ tán gặp sự cố, tạo ra Mimic và khiến khuôn viên bị cách ly. Nhóm tham khảo cảm giác chờ đợi từ *Five Nights at Freddy's*, quan sát và điều tra từ *Phasmophobia*, cùng việc chuẩn bị tài nguyên từ *Don't Starve*. Game kết hợp những ý tưởng đó với bối cảnh trường đại học và mục tiêu cứu hộ hữu hạn.”

---

## Slide 4 — Player Experience

**Trên slide**

> Explore familiar campus spaces  
> Choose your own base  
> Manage limited resources  
> Question suspicious encounters  
> Defend, then escape

**Minh họa:** Ảnh campus kèm ba điểm nhấn đồ họa: exploration, base, rescue. Không gắn vị trí nhiệm vụ cố định vì chúng thay đổi theo ván.

**Lời thuyết trình:** “Người chơi không chỉ đi theo một tuyến nhiệm vụ cố định. Nhóm phải quyết định nên đi tìm vật tư hay nhiệm vụ, chọn một tòa nhà làm căn cứ, rồi cân nhắc khi gặp nhân vật đáng ngờ. Mục tiêu là tạo ra các quyết định có ý nghĩa trong một không gian quen thuộc.”

---

## Slide 5 — Core Gameplay Loop

**Trên slide**

> Explore and gather  
> Complete rescue objectives  
> Prepare and defend  
> Repeat across five days  
> Signal and board

**Minh họa:** Dùng sơ đồ [Core gameplay loop](../FIVE_NIGHTS_AT_BÁCH_KHOA_CC02____GROUP_07/diagrams/submission/core_loop.png); đặt chữ ngắn bên cạnh hoặc chỉ giữ sơ đồ nếu chữ trong ảnh vẫn đọc được khi chiếu.

**Lời thuyết trình:** “Vòng lặp chính bắt đầu bằng khám phá và thu thập vật tư ban ngày. Người chơi thực hiện các mục tiêu cứu hộ theo bất kỳ thứ tự nào, quay về sửa chữa và chuẩn bị phòng thủ, sau đó đối phó các đợt tấn công ban đêm. Sau đêm thứ năm và khi đã phát tín hiệu, nhóm tiến đến sân thể thao để lên trực thăng.”

---

## Slide 6 — Five-Day Pacing

**Trên slide**

> Each day: 12 minutes  
> Nights: 5–5–5–6–8 minutes  
> Waves: 0–2–2–3–4  
> Eleven scheduled night waves  
> One to two hours

**Minh họa:** Tự dựng timeline năm cột. Phần ngày có chiều dài bằng nhau; phần đêm hiển thị thời lượng và số wave tương ứng. Ghi rõ đơn vị là **real minutes**.

**Lời thuyết trình:** “Mỗi ngày kéo dài 12 phút thực. Năm đêm lần lượt kéo dài 5, 5, 5, 6 và 8 phút; số wave tương ứng là 0, 2, 2, 3 và 4, tổng cộng 11 wave trong năm đêm. Nhịp này hướng đến một lượt chơi khoảng một đến hai giờ; con số thực tế cần được xác nhận bằng playtest.”

---

## Slide 7 — Survival & Combat

**Trên slide**

> Health, food and water  
> Eight inventory slots  
> Melee and limited ammunition  
> Craft and repair defenses  
> Friendly fire: five HP

**Minh họa:** [HUD đen trắng](../FIVE_NIGHTS_AT_BÁCH_KHOA_CC02____GROUP_07/ui_mockups/hud_wireframe_bw.png), phóng to cụm thanh trạng thái và hành trang; có thể bổ sung icon thức ăn, nước và đạn.

**Lời thuyết trình:** “Người chơi quản lý máu, thức ăn, nước và hành trang tám ô. Họ bắt đầu bằng vũ khí cận chiến, sau đó có thể tìm súng và đạn giới hạn; vật liệu được dùng để chế tạo hoặc sửa phòng thủ. Mỗi đòn hoặc phát bắn trúng đồng đội gây 5 HP, nên nhóm cần phân biệt mục tiêu cẩn thận.”

---

## Slide 8 — Threats & Mimic

**Trên slide**

> Mimic copies NPCs and players  
> Observe unusual behavior  
> Verify with UV or scanner  
> Creatures ambush using sound  
> Machines patrol and detect

**Minh họa:** Ba hình đại diện cho Mimic, sinh vật và máy tuần tra. Có thể dùng [AI state flow](../FIVE_NIGHTS_AT_BÁCH_KHOA_CC02____GROUP_07/diagrams/submission/ai_flow.png) làm hình phụ; đưa bản lớn vào slide dự phòng nếu chữ quá nhỏ.

**Lời thuyết trình:** “Mimic giả dạng NPC hoặc người chơi, nhưng phải có dấu hiệu bất thường để người chơi quan sát; UV và scanner là công cụ kiểm tra bổ sung. Ngoài ra, sinh vật đột biến nghe tiếng động và phục kích, còn máy móc tuần tra bằng ánh sáng hoặc âm thanh. Mỗi loại vì vậy tạo một cách tiếp cận khác nhau.”

---

## Slide 9 — Trust & Survivors

**Trên slide**

> NPCs offer help and information  
> Shared Trust: zero to 100  
> Innocent hit: minus ten  
> Valid assistance: plus ten  
> Low Trust limits trade

**Minh họa:** Thanh Trust ba đoạn: **70–100 Normal**, **30–69 Wary**, **0–29 Essential only**. Dùng màu và nhãn chữ để không phụ thuộc hoàn toàn vào màu.

**Lời thuyết trình:** “Các NPC sống sót cung cấp thông tin, vật tư và nhiệm vụ phụ. Trust là giá trị chung của cả nhóm, bắt đầu ở 100; tấn công nhầm NPC vô tội giảm 10, còn giúp đỡ hợp lệ tăng 10. Khi Trust giảm, việc trao đổi bị hạn chế, nhưng thông tin cần thiết cho cứu hộ không bị khóa vĩnh viễn.”

---

## Slide 10 — Campus as Your Base

**Trên slide**

> Choose any campus building  
> Twenty-three planned base profiles  
> Upgrade power, storage, defenses  
> Move supplies between bases  
> Fixed upgrades stay behind

**Minh họa:** [Ảnh campus Studio](../FIVE_NIGHTS_AT_BÁCH_KHOA_CC02____GROUP_07/assets/campus_studio_overview.png), đánh dấu B1, thư viện A2 và một xưởng như **ví dụ minh họa** nếu đã kiểm tra vị trí chính xác. Nếu chưa chắc vị trí, dùng ba biểu tượng tòa nhà bên cạnh ảnh.

**Lời thuyết trình:** “Thiết kế dự kiến cho phép chọn bất kỳ tòa nào trong 23 tòa làm căn cứ, với các điểm nâng cấp điện, lưu trữ và phòng thủ phù hợp công năng. Nhóm có thể chuyển căn cứ nhưng phải tự mang vật tư; nâng cấp cố định vẫn ở tòa cũ. Ảnh là preview campus trong Studio, chưa chứng minh cả 23 căn cứ đã được tích hợp gameplay.”

---

## Slide 11 — Missions & Hidden Spaces

**Trên slide**

> Restore power  
> Find radio frequency  
> Recover transmitter components  
> Locations vary each run  
> Secrets offer optional rewards

**Minh họa:** Ba icon nhiệm vụ nối vào biểu tượng radio; thêm một nhánh phụ tới phòng bí mật. Có thể dùng ảnh campus nhưng không đánh dấu A2/A3/B4 thành vị trí nhiệm vụ cố định.

**Lời thuyết trình:** “Để phát tín hiệu, nhóm cần hoàn thành ba nhiệm vụ: khôi phục điện, tìm tần số và lấy linh kiện máy phát. Thứ tự hoàn thành là tùy ý; vị trí nhiệm vụ được chọn trong những tòa phù hợp và đánh dấu trên bản đồ mỗi ván. Phòng bí mật và tầng hầm chỉ cung cấp tài nguyên hoặc thông tin bổ sung, không bắt buộc để thoát.”

---

## Slide 12 — Rescue & Outcomes

**Trên slide**

> Signal anytime after preparation  
> Helicopter arrives after night five  
> Four-minute arrival wait  
> Three-minute boarding window  
> Rescue recorded per player

**Minh họa:** [Sơ đồ helicopter](../FIVE_NIGHTS_AT_BÁCH_KHOA_CC02____GROUP_07/diagrams/submission/helicopter.png). Vì sơ đồ khá dày, dùng bản rút gọn trên slide chính và giữ ảnh đầy đủ cho slide dự phòng.

**Lời thuyết trình:** “Người chơi có thể phát tín hiệu ngay khi đủ điều kiện, nhưng trực thăng chỉ đến sau khi đêm thứ năm kết thúc, với khoảng chờ bốn phút sau khi cả hai điều kiện đã hoàn tất. Nếu chưa phát tín hiệu vào cuối đêm năm, nhóm có thêm mười phút, trong đó có tối đa ba wave bổ sung. Khi trực thăng hạ cánh, nhóm có ba phút để lên; người đã lên có thể bỏ phiếu cất cánh sớm, và kết quả được ghi riêng cho từng người.”

---

## Slide 13 — Art, Audio & UX

**Trên slide**

> Low-poly Vietnamese campus  
> Moderate, readable horror  
> Clear HUD and warnings  
> Sound supports threat awareness  
> Accessible visual and audio cues

**Minh họa:** Kết hợp [HUD wireframe](../FIVE_NIGHTS_AT_BÁCH_KHOA_CC02____GROUP_07/ui_mockups/hud_wireframe_bw.png) và [menu/lobby wireframe](../FIVE_NIGHTS_AT_BÁCH_KHOA_CC02____GROUP_07/ui_mockups/menu_lobby_wireframe_bw.png). Có thể thêm một dải màu lấy từ GDD; ghi **concept** dưới mockup.

**Lời thuyết trình:** “Hình ảnh sử dụng phong cách low-poly với cảm hứng từ môi trường đại học Việt Nam, tạo không khí căng thẳng vừa phải nhưng vẫn nhìn rõ lối đi. HUD thể hiện trạng thái sinh tồn, nhiệm vụ và nhóm. Âm thanh giúp nhận biết bước chân, máy tuần tra và cảnh báo wave; thông tin quan trọng cũng có tín hiệu hình ảnh hoặc chữ.”

---

## Slide 14 — Technical Architecture

**Trên slide**

> Roblox Studio and Luau  
> Server validates critical actions  
> Clients handle input and UI  
> Host owns saved world  
> Resume with friends

**Minh họa:** [Sơ đồ server](../FIVE_NIGHTS_AT_BÁCH_KHOA_CC02____GROUP_07/diagrams/submission/server.png), đặt lớn; có thể chỉ giữ 3 dòng chữ trên slide nếu sơ đồ cần thêm không gian.

**Lời thuyết trình:** “Game được thiết kế cho Roblox bằng Luau. Client phụ trách điều khiển và giao diện, còn server xác thực sát thương, AI, nhiệm vụ, vật phẩm và thời gian để giảm sai lệch giữa người chơi. Thế giới được lưu theo chủ phòng để nhóm có thể tiếp tục ở phiên sau; các hệ thống này vẫn cần triển khai và kiểm thử cho bản sinh tồn.”

---

## Slide 15 — Scope & Next Steps

**Trên slide**

> Prototype one campus route  
> Validate one Mimic  
> Test combat and survival  
> Expand multiplayer and persistence  
> Playtest, balance, profile

**Minh họa:** Roadmap ba giai đoạn: **Prototype → Systems → Full campus**. Dưới roadmap dùng các mốc nhỏ cho Mimic, combat, save/co-op và rescue; không cần ghi ngày chưa được nhóm thống nhất.

**Lời thuyết trình:** “Phạm vi đầy đủ gồm 23 căn cứ, một đến bốn người chơi, nhiều loại kẻ địch và cứu hộ bằng trực thăng. Để kiểm soát rủi ro, nhóm bắt đầu với một khu graybox và một Mimic có chuyển trạng thái Chase/Search rõ ràng, sau đó kiểm tra combat, sinh tồn, lưu trữ và co-op. Những bước tiếp theo là playtest, cân bằng và đo hiệu năng trên thiết bị mục tiêu. Xin cảm ơn thầy cô và các bạn.”

---

## Slide dự phòng — Cơ chế chi tiết

Các slide dưới đây chỉ dùng khi có thời gian hoặc khi trả lời câu hỏi. Tiếp tục áp dụng giới hạn 5×5; lời giải thích và bảng chi tiết nằm trong speaker notes.

### A. Wave scaling

> Solo: 10 / 14 / 18 / 24  
> Each extra player: +50%  
> Active caps: 20–50  
> Count fixed per wave  
> Balance requires playtesting

**Minh họa:** Biểu đồ cột số kẻ **mỗi wave**, không phải tổng mỗi đêm. Ghi đêm 2–5 bên dưới. Giải thích trần hoạt động cho nhóm 1–4 người là 20 / 30 / 40 / 50; các trần này không đồng nghĩa tất cả kẻ xuất hiện cùng lúc.

**Lời thuyết trình:** “Số kẻ mỗi wave khi solo tăng từ 10 lên 24 qua đêm hai đến năm. Mỗi người thêm tăng 50% số lượng cơ bản, còn số kẻ hoạt động đồng thời bị giới hạn theo quy mô nhóm. Các giá trị được chọn làm mục tiêu thiết kế, cần kiểm tra thực tế về độ khó và hiệu năng.”

### B. Revive & respawn

> Thirty seconds to revive  
> Hold interaction for five  
> Three respawns per player  
> Items drop on respawn  
> Teammates can retrieve bags

**Minh họa:** Timeline ngang: **Downed → Revive window → Revive / Respawn / Spectate**.

**Lời thuyết trình:** “Trong co-op, đồng đội có 30 giây để cứu người bị hạ bằng thao tác giữ năm giây. Nếu không cứu kịp, người còn lượt sẽ tự hồi sinh tại căn cứ, dùng một trong ba lượt và để lại túi đồ tại nơi bị hạ. Khi đã hết lượt, họ vẫn có cửa sổ cứu; nếu không được cứu kịp, họ chuyển sang theo dõi.”

### C. Rescue vote

> Boarding window: three minutes  
> Vote lasts ten seconds  
> Majority aboard can depart  
> Roster change cancels vote  
> Each result is individual

**Minh họa:** [Sơ đồ helicopter đầy đủ](../FIVE_NIGHTS_AT_BÁCH_KHOA_CC02____GROUP_07/diagrams/submission/helicopter.png), phóng lớn trên slide.

**Lời thuyết trình:** “Trực thăng chờ tối đa ba phút. Người trên máy bay có thể mở phiếu cất cánh, phiếu kéo dài tối đa mười giây và cần đa số người đang ở trên máy bay đồng ý. Nếu có người lên hoặc xuống trong lúc bỏ phiếu, phiếu bị hủy; đến hết thời hạn ba phút máy bay vẫn cất cánh.”

---

## Ghi chú dựng slide

- **5×5:** Mỗi slide chính tối đa năm dòng nội dung, mỗi dòng tối đa năm từ; tiêu đề và chú thích nguồn hình đặt riêng. Không dán phần lời thuyết trình lên slide.
- **Bố cục:** Dành khoảng hai phần ba slide cho hình, sơ đồ hoặc timeline; chữ đủ lớn để nhìn từ cuối phòng. Những sơ đồ phức tạp nên rút gọn trên slide chính và dùng bản đầy đủ ở phần dự phòng.
- **Tính nhất quán:** Dùng bảng màu của GDD: navy `#132437`, teal `#1D907F`, amber `#C6954B` và nền sáng `#F1F5F7`. Đảm bảo độ tương phản; màu không phải dấu hiệu duy nhất.
- **Nguồn và tình trạng:** Ghi “Studio preview” cho ảnh campus, “Concept mockup” cho HUD/menu và trích nguồn nếu thêm hình bên ngoài. Không mô tả cơ chế sinh tồn, co-op bốn người hay FPS mục tiêu như kết quả đã kiểm thử.
- **Thời gian:** Tập thử và điều chỉnh theo thời lượng giảng viên quy định; không chia thời gian cứng cho từng người khi nhóm chưa phân công.
