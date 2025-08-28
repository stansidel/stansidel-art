// Enhanced image loader with network condition detection
class ImageLoader {
    constructor() {
        this.networkInfo = this.detectNetworkConditions();
        this.setupNetworkMonitoring();
    }

    // Detect network conditions
    detectNetworkConditions() {
        const connection = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
        
        if (connection) {
            return {
                effectiveType: connection.effectiveType || 'unknown',
                downlink: connection.downlink || 0,
                rtt: connection.rtt || 0,
                saveData: connection.saveData || false
            };
        }
        
        return {
            effectiveType: 'unknown',
            downlink: 0,
            rtt: 0,
            saveData: false
        };
    }

    // Setup network monitoring
    setupNetworkMonitoring() {
        if ('connection' in navigator) {
            navigator.connection.addEventListener('change', () => {
                this.networkInfo = this.detectNetworkConditions();
                this.adjustLoadingStrategy();
            });
        }
    }

    // Adjust loading strategy based on network conditions
    adjustLoadingStrategy() {
        const { effectiveType, downlink, saveData } = this.networkInfo;
        
        if (saveData || effectiveType === 'slow-2g' || effectiveType === '2g') {
            // Use lower quality images for slow connections
            this.loadLowQualityImages();
        } else if (effectiveType === '3g' || downlink < 1) {
            // Use medium quality for moderate connections
            this.loadMediumQualityImages();
        } else {
            // Use high quality for fast connections
            this.loadHighQualityImages();
        }
    }

    // Load low quality images for slow connections
    loadLowQualityImages() {
        const images = document.querySelectorAll('img[data-low-quality]');
        images.forEach(img => {
            if (img.dataset.lowQuality && !img.src.includes('low-quality')) {
                img.src = img.dataset.lowQuality;
            }
        });
    }

    // Load medium quality images
    loadMediumQualityImages() {
        const images = document.querySelectorAll('img[data-medium-quality]');
        images.forEach(img => {
            if (img.dataset.mediumQuality && !img.src.includes('medium-quality')) {
                img.src = img.dataset.mediumQuality;
            }
        });
    }

    // Load high quality images
    loadHighQualityImages() {
        const images = document.querySelectorAll('img[data-high-quality]');
        images.forEach(img => {
            if (img.dataset.highQuality && !img.src.includes('high-quality')) {
                img.src = img.dataset.highQuality;
            }
        });
    }

    // Enhanced image loading with retry logic
    loadImage(img, retryCount = 0) {
        const maxRetries = 3;
        const retryDelay = 1000 * Math.pow(2, retryCount); // Exponential backoff

        return new Promise((resolve, reject) => {
            const timeout = setTimeout(() => {
                if (retryCount < maxRetries) {
                    console.log(`Retrying image load for ${img.src} (attempt ${retryCount + 1})`);
                    setTimeout(() => this.loadImage(img, retryCount + 1), retryDelay);
                } else {
                    reject(new Error('Image load failed after max retries'));
                }
            }, 5000); // 5 second timeout

            img.onload = () => {
                clearTimeout(timeout);
                resolve(img);
            };

            img.onerror = () => {
                clearTimeout(timeout);
                if (retryCount < maxRetries) {
                    setTimeout(() => this.loadImage(img, retryCount + 1), retryDelay);
                } else {
                    reject(new Error('Image load failed'));
                }
            };

            // If image is already loaded, resolve immediately
            if (img.complete && img.naturalWidth > 0) {
                clearTimeout(timeout);
                resolve(img);
            }
        });
    }

    // Progressive loading with placeholder
    progressiveLoad(img, placeholderSrc, finalSrc) {
        // Load placeholder first
        img.src = placeholderSrc;
        
        // Then load final image
        const finalImg = new Image();
        finalImg.onload = () => {
            img.src = finalSrc;
            img.classList.add('loaded');
        };
        finalImg.src = finalSrc;
    }

    // Lazy loading with intersection observer
    setupLazyLoading() {
        if ('IntersectionObserver' in window) {
            const imageObserver = new IntersectionObserver((entries, observer) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        const img = entry.target;
                        this.loadImage(img).then(() => {
                            observer.unobserve(img);
                        }).catch(error => {
                            console.error('Failed to load image:', error);
                            this.showImageError(img);
                        });
                    }
                });
            }, {
                rootMargin: '50px 0px',
                threshold: 0.01
            });

            const lazyImages = document.querySelectorAll('img[data-src]');
            lazyImages.forEach(img => imageObserver.observe(img));
        }
    }

    // Show image error state
    showImageError(img) {
        const container = img.closest('.progressive-image');
        if (container) {
            container.classList.add('image-error');
        }
        
        // Replace with error placeholder
        img.style.display = 'none';
        const errorDiv = document.createElement('div');
        errorDiv.className = 'image-error';
        errorDiv.innerHTML = '<span>⚠️ Failed to load</span>';
        img.parentNode.appendChild(errorDiv);
    }

    // Initialize the image loader
    init() {
        this.setupLazyLoading();
        this.adjustLoadingStrategy();
        
        // Add loading states to existing images
        document.addEventListener('DOMContentLoaded', () => {
            this.setupLoadingStates();
        });
    }

    // Setup loading states for existing images
    setupLoadingStates() {
        const images = document.querySelectorAll('img:not([data-processed])');
        images.forEach(img => {
            img.setAttribute('data-processed', 'true');
            
            if (!img.complete) {
                this.addLoadingState(img);
            }
        });
    }

    // Add loading state to an image
    addLoadingState(img) {
        const container = img.closest('.progressive-image') || img.parentNode;
        if (!container.querySelector('.image-loading-overlay')) {
            const overlay = document.createElement('div');
            overlay.className = 'image-loading-overlay';
            overlay.innerHTML = `
                <div class="loading-content">
                    <div class="loading-spinner"></div>
                    <div class="loading-text">Loading...</div>
                </div>
            `;
            container.appendChild(overlay);
            
            // Remove overlay when image loads
            img.addEventListener('load', () => {
                overlay.classList.add('hidden');
                setTimeout(() => overlay.remove(), 300);
            });
        }
    }
}

// Initialize image loader when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.imageLoader = new ImageLoader();
    window.imageLoader.init();
});

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ImageLoader;
}
