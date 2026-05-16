import type { NextConfig } from "next";

const PORTFOLIO_URL = "https://portfolio-2-youssef-ait-elourfs-projects.vercel.app";
const CV_ADAPTER_URL = process.env.CV_ADAPTER_URL ?? "https://cv-adapter-youssef-ait-elourfs-projects.vercel.app";

const nextConfig: NextConfig = {
  async redirects() {
    return [
      { source: "/", destination: "/portfolio", permanent: true },
      { source: "/admin", destination: "/admin/login", permanent: false },
    ];
  },
  async rewrites() {
    return [
      // Portfolio
      { source: "/portfolio", destination: `${PORTFOLIO_URL}/portfolio` },
      { source: "/portfolio/:path*", destination: `${PORTFOLIO_URL}/portfolio/:path*` },
      // CV Adapter (proxied après auth middleware)
      { source: "/admin/cv-adapter", destination: `${CV_ADAPTER_URL}/admin/cv-adapter` },
      { source: "/admin/cv-adapter/:path*", destination: `${CV_ADAPTER_URL}/admin/cv-adapter/:path*` },
    ];
  },
};

export default nextConfig;
