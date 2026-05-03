#!/bin/bash

# Thể hiện phong cách Bong bóng đen - Khiên đỏ qua ASCII Art
RED='\033[0;31m'
BLACK='\033[0;30m'
BG_BLACK='\033[40m'
NC='\033[0m' # No Color

echo -e "${BG_BLACK}${RED}"
echo "    ___________________________________________________"
echo "   /                                                   \\"
echo "  |    [ RED SHIELD ] - WEBSHİELD ACTİVATED             |"
echo "  |         🛡️  PROTECTİNG YOUR BUBBLE  🛡️             |"
echo "   \\___________________________________________________/"
echo -e "${NC}"

# 1. Cấu hình DNS an toàn (OpenDNS)
echo -e "${RED}[+] Đang thiết lập DNS an toàn (OpenDNS)...${NC}"
cat <<EOF > /etc/resolv.conf
nameserver 208.67.222.222
nameserver 208.67.220.220
EOF

# 2. Cấu hình Firewall Iptables - Chống DDOS cơ bản
echo -e "${RED}[+] Đang kích hoạt tường lửa hệ thống...${NC}"
# Xóa các quy tắc cũ
iptables -F
# Cho phép lưu lượng truy cập nội bộ (loopback)
iptables -A INPUT -i lo -j ACCEPT
# Cho phép các kết nối đã thiết lập
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
# Mở cổng Web (80, 443) và SSH (22 - hãy đổi nếu bạn dùng cổng khác)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT

# Chống Scan Port và Bot độc
iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP
iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

# Giới hạn kết nối (Rate Limiting) để chống Spam/Bot
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT

# 3. Tối ưu hóa Nginx Security
echo -e "${RED}[+] Đang tạo cấu hình bảo mật Nginx...${NC}"
cat <<EOF > /etc/nginx/conf.d/red_shield.conf
# Chống Clickjacking
add_header X-Frame-Options "SAMEORIGIN";
# Chống XSS
add_header X-XSS-Protection "1; mode=block";
# Chống Sniffing
add_header X-Content-Type-Options "nosniff";

# Giới hạn Rate Limit cho mỗi IP
limit_req_zone \$binary_remote_addr zone=one:10m rate=10r/s;

# Chặn các User-Agent của Bot độc phổ biến
if (\$http_user_agent ~* (AhrefsBot|DotBot|SemrushBot|MJ12bot|baikuspider)) {
    return 403;
}
EOF

# Kiểm tra và khởi động lại Nginx
nginx -t && systemctl restart nginx

echo -e "${BG_BLACK}${RED}>>> HỆ THỐNG ĐÃ ĐƯỢC BẢO VỆ TRONG BONG BÓNG ĐEN KHIÊN ĐỎ <<<${NC}"
