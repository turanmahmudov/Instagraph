#include <src/imageprocessor.h>
#include <src/offscreenrenderer.h>

#include <QQmlComponent>
#include <QQuickItem>
#include <QDebug>
#include <QQmlProperty>
#include <QDir>

#include <QSharedPointer>
#include <QQuickItemGrabResult>
#include <QVariant>

#define EFFECTS_VIGNETTE_DEFAULT 0.0
#define EFFECTS_TEMPERATURE_DEFAULT 0.5
#define EFFECTS_BRIGHTNESS_DEFAULT 0.5
#define EFFECTS_CONTRAST_DEFAULT 0.5
#define EFFECTS_HAXISADJUST_DEFAULT 0.0
#define EFFECTS_SATURATION_DEFAULT 0.5
#define EFFECTS_CLARITY_DEFAULT 0.0
#define EFFECTS_SHARPEN_DEFAULT 0.0
#define EFFECTS_HIGHLIGHTS_DEFAULT 1.0
#define EFFECTS_SHADOWS_DEFAULT 0.0

#define FILTER_OPACITY_DEFAULT 1.0

#define UPDATE_INTERVAL_MSECS 60

ImageProcessor::ImageProcessor(QObject *parent)
    : QObject(parent)
    , m_filterUrl("")
    , m_filterOpacity(FILTER_OPACITY_DEFAULT)
    , m_vignetteOpacity(EFFECTS_VIGNETTE_DEFAULT)
    , m_temperature(EFFECTS_TEMPERATURE_DEFAULT)
    , m_brightness(EFFECTS_BRIGHTNESS_DEFAULT)
    , m_contrast(EFFECTS_CONTRAST_DEFAULT)
    , m_hAxisAdjust(EFFECTS_HAXISADJUST_DEFAULT)
    , m_saturation(EFFECTS_SATURATION_DEFAULT)
    , m_clarity(EFFECTS_CLARITY_DEFAULT)
    , m_sharpen(EFFECTS_SHARPEN_DEFAULT)
    , m_highlights(EFFECTS_HIGHLIGHTS_DEFAULT)
    , m_shadows(EFFECTS_SHADOWS_DEFAULT)
    , m_offscreenRenderer(0)
    , m_imageContainer(0)
    , m_filter(0)
{
    m_timer = new QTimer();
    m_timer->setSingleShot(true);
    m_timer->setInterval(UPDATE_INTERVAL_MSECS);

    connect(m_timer, &QTimer::timeout, this, &ImageProcessor::updateQmlParameters);

    connect(this, &ImageProcessor::vignetteOpacityChanged, this, &ImageProcessor::startQmlParametersTimer);
    connect(this, &ImageProcessor::temperatureChanged, this, &ImageProcessor::startQmlParametersTimer);
    connect(this, &ImageProcessor::brightnessChanged, this, &ImageProcessor::startQmlParametersTimer);
    connect(this, &ImageProcessor::contrastChanged, this, &ImageProcessor::startQmlParametersTimer);
    connect(this, &ImageProcessor::hAxisAdjustChanged, this, &ImageProcessor::startQmlParametersTimer);
    connect(this, &ImageProcessor::saturationChanged, this, &ImageProcessor::startQmlParametersTimer);
    connect(this, &ImageProcessor::clarityChanged, this, &ImageProcessor::startQmlParametersTimer);
    connect(this, &ImageProcessor::filterOpacityChanged, this, &ImageProcessor::startQmlParametersTimer);
    connect(this, &ImageProcessor::sharpenChanged, this, &ImageProcessor::startQmlParametersTimer);
    connect(this, &ImageProcessor::highlightsChanged, this, &ImageProcessor::startQmlParametersTimer);
    connect(this, &ImageProcessor::shadowsChanged, this, &ImageProcessor::startQmlParametersTimer);

    m_offscreenRenderer = new OffscreenRenderer(this);
    connect(m_offscreenRenderer, &OffscreenRenderer::contentItemChanged, this, &ImageProcessor::init);

}

ImageProcessor::~ImageProcessor()
{
    delete m_filter;
    delete m_imageContainer;
    delete m_offscreenRenderer;
    delete m_timer;
}

void ImageProcessor::setFilterUrl(const QUrl &url)
{
    if (url == m_filterUrl)
        return;

    m_filterUrl = url;
    emit filterUrlChanged();

    if (m_filter) {
        delete m_filter;
        m_filter = 0;
    }

    QQmlEngine* engine = qmlEngine(this);
    QQmlComponent component(engine, url, m_imageContainer);

    // It should be FilterBase
    m_filter = qobject_cast<QQuickItem*>(component.create(qmlContext(m_imageContainer)));

    emit filterChanged();
}

void ImageProcessor::setFilterOpacity(const qreal &opacity)
{
    if (opacity == m_filterOpacity)
        return;

    if (opacity < 0.0 || opacity > 1.0) {
        qWarning() << Q_FUNC_INFO << "Filter opacity must be a value between 0.0 and 1.0.";
        return;
    }

    m_filterOpacity = opacity;
    emit filterOpacityChanged();
}

void ImageProcessor::setVignetteOpacity(const qreal &opacity)
{
    if (opacity == m_vignetteOpacity)
        return;

    if (opacity < 0.0 || opacity > 1.0) {
        qWarning() << Q_FUNC_INFO << "Vignette opacity must be a value between 0.0 and 1.0.";
        return;
    }

    m_vignetteOpacity = opacity;
    emit vignetteOpacityChanged();
}

void ImageProcessor::setTemperature(const qreal &temperature)
{
    if (temperature == m_temperature)
        return;

    if (temperature < 0.0 || temperature > 1.0) {
        qWarning() << Q_FUNC_INFO << "temperature must be a value between 0.0 and 1.0.";
        return;
    }

    m_temperature = temperature;
    emit temperatureChanged();
}

// Image brightness adjustment. Valid brightness adjustment values range between -100 and 100, with a default of 0.
void ImageProcessor::setBrightness(const qreal &brightness)
{
    if (brightness == m_brightness)
        return;

    if (brightness < 0.0 || brightness > 1.0) {
        qWarning() << Q_FUNC_INFO << "Brightness must be a value between 0.0 and 1.0.";
        return;
    }

    m_brightness = brightness;
    emit brightnessChanged();
}

// Image contrast adjustment. Valid contrast adjustment values range between -100 and 100, with a default of 0.
void ImageProcessor::setContrast(const qreal &contrast)
{
    if (contrast == m_contrast)
        return;

    if (contrast < 0.0 || contrast > 1.0) {
        qWarning() << Q_FUNC_INFO << "Contrast must be a value between 0.0 and 1.0.";
        return;
    }

    m_contrast = contrast;
    emit contrastChanged();
}

void ImageProcessor::setHAxisAdjust(const qreal &adjust)
{
    if (adjust == m_hAxisAdjust)
        return;

    if (adjust < -25 || adjust > 25) {
        qWarning() << Q_FUNC_INFO << "hAxisAdjust must be a value between -25 and 25.";
        return;
    }

    m_hAxisAdjust = adjust;
    emit hAxisAdjustChanged();
}

// Image saturation adjustment. Valid saturation adjustment values range between -1.0 and 1.0, the default is 0.
void ImageProcessor::setSaturation(const qreal &saturation)
{
    if (saturation == m_saturation)
        return;

    if (saturation < -1.0 || saturation > 1.0) {
        qWarning() << Q_FUNC_INFO << "Saturation must be a value between -1.0 and 1.0.";
        return;
    }

    m_saturation = saturation;
    emit saturationChanged();
}

void ImageProcessor::setClarity(const qreal &clarity)
{
    if (clarity == m_clarity)
        return;

    if (clarity < 0.0 || clarity > 1.0) {
        qWarning() << Q_FUNC_INFO << "clarity must be a value between 0.0 and 1.0.";
        return;
    }

    m_clarity = clarity;
    emit clarityChanged();
}

void ImageProcessor::setSharpen(const qreal &sharpen)
{
    if (sharpen == m_sharpen)
        return;

    if (sharpen < 0.0 || sharpen > 1.0) {
        qWarning() << Q_FUNC_INFO << "sharpen must be a value between 0.0 and 1.0.";
        return;
    }

    m_sharpen = sharpen;
    emit sharpenChanged();
}

void ImageProcessor::setHighlights(const qreal &highlights)
{
    if (highlights == m_highlights)
        return;

    if (highlights < 0.0 || highlights > 1.0) {
        qWarning() << Q_FUNC_INFO << "highlights must be a value between 0.0 and 1.0.";
        return;
    }

    m_highlights = highlights;
    emit highlightsChanged();
}

void ImageProcessor::setShadows(const qreal &shadows)
{
    if (shadows == m_shadows)
        return;

    if (shadows < 0.0 || shadows > 1.0) {
        qWarning() << Q_FUNC_INFO << "shadows must be a value between 0.0 and 1.0.";
        return;
    }

    m_shadows = shadows;
    emit shadowsChanged();
}

QString ImageProcessor::loadedImagePath() const
{
    if (!m_imageContainer)
        return QString();

    return m_imageContainer->property("imagePath").toString();
}

void ImageProcessor::classBegin()
{
    /* Do nothing */
}

void ImageProcessor::componentComplete()
{
    //if (m_offscreenRenderer->contentItem())
        //qDebug() << Q_FUNC_INFO << "Hey me";

    QQmlEngine* engine = qmlEngine(this);

    // FIXME: Hackish! It would be much better to use .qrc resources.
    QUrl containerQmlPath = QUrl(QStringLiteral("qrc:///qml/components/ImageContainer.qml"));
    //qDebug() << containerQmlPath;

    QQmlComponent component(engine, containerQmlPath, m_offscreenRenderer->contentItem());
    m_imageContainer = qobject_cast<QQuickItem*>(component.create(qmlContext(m_offscreenRenderer->contentItem())));

    if (m_imageContainer)
        m_imageContainer->setParent(m_offscreenRenderer->contentItem());
}

QQuickItem *ImageProcessor::__output() const
{
    return m_imageContainer;
}

QQuickItem *ImageProcessor::__originalImageOutput() const
{
    if (!m_imageContainer)
        return 0;

    return qvariant_cast<QQuickItem*>(m_imageContainer->property("__originalImg"));
}

bool ImageProcessor::saveToDisk(const QString &destPath, int quality, int size)
{
    if (!m_offscreenRenderer || !m_imageContainer)
        return false;

    QQuickItem* item = m_imageContainer;

    // Set size of the object
    qDebug() << Q_FUNC_INFO << "Set container size:" << QMetaObject::invokeMethod(item, "setSize", Qt::DirectConnection, Q_ARG(QVariant, size));

    // Force update
    item->window()->update();

    QSharedPointer<QQuickItemGrabResult> grabber;
    grabber = item->grabToImage();

    if (!grabber) {
        //qDebug() << Q_FUNC_INFO << "failed to grab item!";
        return false;
    }

    // Test
    m_grabber = grabber;
    m_destPath = destPath;
    m_quality = quality;
    connect(m_grabber.data(), &QQuickItemGrabResult::ready, this, &ImageProcessor::grabConnect);

    return true;
}

void ImageProcessor::grabConnect()
{
    QImage img = m_grabber.data()->image();

    //qDebug() << img.isNull() << img.size();

    bool r = img.save(m_destPath, "JPG", m_quality);
    //qDebug() << "Image saved?" << bool(r);

    emit imageSaved(m_destPath);
}

void ImageProcessor::loadImage(const QString &imagePath)
{
    QQmlProperty::write(m_imageContainer, "imagePath", imagePath);
    emit loadedImagePathChanged();

    setBrightness(EFFECTS_BRIGHTNESS_DEFAULT);
    setTemperature(EFFECTS_TEMPERATURE_DEFAULT);
    setContrast(EFFECTS_CONTRAST_DEFAULT);
    setHAxisAdjust(EFFECTS_HAXISADJUST_DEFAULT);
    setFilterOpacity(FILTER_OPACITY_DEFAULT);
    setSaturation(EFFECTS_SATURATION_DEFAULT);
    setVignetteOpacity(EFFECTS_VIGNETTE_DEFAULT);
    setClarity(EFFECTS_CLARITY_DEFAULT);
    setSharpen(EFFECTS_SHARPEN_DEFAULT);
    setHighlights(EFFECTS_HIGHLIGHTS_DEFAULT);
    setShadows(EFFECTS_SHADOWS_DEFAULT);

    updateQmlParameters();

    emit __outputChanged();
}

bool ImageProcessor::setProperty(const QString &property, const QVariant &value)
{
    return QQmlProperty::write(this, property, value);
}

QVariant ImageProcessor::getProperty(const QString &property)
{
    return QQmlProperty::read(this, property);
}

void ImageProcessor::init()
{
}

void ImageProcessor::startQmlParametersTimer()
{
    if (!m_timer->isActive())
        m_timer->start();
}

void ImageProcessor::updateQmlParameters()
{
    if (!m_imageContainer)
        return;

    //qDebug() << Q_FUNC_INFO;

    QQmlProperty::write(m_imageContainer, "vignetteOpacity", m_vignetteOpacity);
    QQmlProperty::write(m_imageContainer, "temperature", m_temperature);
    QQmlProperty::write(m_imageContainer, "brightness", m_brightness);
    QQmlProperty::write(m_imageContainer, "contrast", m_contrast);
    QQmlProperty::write(m_imageContainer, "filterOpacity", m_filterOpacity);
    QQmlProperty::write(m_imageContainer, "hAxisAdjust", m_hAxisAdjust);
    QQmlProperty::write(m_imageContainer, "saturation", m_saturation);
    QQmlProperty::write(m_imageContainer, "clarity", m_clarity);
    QQmlProperty::write(m_imageContainer, "sharpen", m_sharpen);
    QQmlProperty::write(m_imageContainer, "highlights", m_highlights);
    QQmlProperty::write(m_imageContainer, "shadows", m_shadows);

    emit imageSettingsChanged();
}

