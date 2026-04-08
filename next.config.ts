import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  typescript: {
    ignoreBuildErrors: true,
  },
  reactStrictMode: false,
  allowedDevOrigins: [
    "preview-chat-31d1b699-aba7-41f4-8bab-10048e8419e9.space.z.ai",
    "preview-chat-837b5052-6f3d-49b6-8042-bae41e89a3e8.space.z.ai",
  ],
};

export default nextConfig;
