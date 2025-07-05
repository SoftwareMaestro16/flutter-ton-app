String shortAddress(String addr, int symbols) {
  return '${addr.substring(0, symbols)}...${addr.substring(addr.length - symbols)}';
}