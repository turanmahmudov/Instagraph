#ifndef IMAGEPROCESSOR_H
#define IMAGEPROCESSOR_H

#include <QObject>
#include <QQmlParserStatus>
#include <QUrl>
#include <QTimer>
#include <QVariant>

#include <QSharedPointer>
#include <QQuickItemGrabResult>

class OffscreenRenderer;

class QQuickItem;

class ImageProcessor : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)
    Q_PROPERTY(QQuickItem* filter READ filter NOTIFY filterChanged)
    Q_PROPERTY(QUrl filterUrl READ filterUrl WRITE setFilterUrl NOTIFY filterUrlChanged)
    Q_PROPERTY(qreal filterOpacity READ filterOpacity WRITE setFilterOpacity NOTIFY filterOpacityChanged)
    Q_PROPERTY(qreal vignetteOpacity READ vignetteOpacity WRITE setVignetteOpacity NOTIFY vignetteOpacityChanged)
    Q_PROPERTY(qreal temperature READ temperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(qreal brightness READ brightness WRITE setBrightness NOTIFY brightnessChanged)
    Q_PROPERTY(qreal contrast READ contrast WRITE setContrast NOTIFY contrastChanged)
    Q_PROPERTY(qreal hAxisAdjust READ hAxisAdjust WRITE setHAxisAdjust NOTIFY hAxisAdjustChanged)
    Q_PROPERTY(qreal saturation READ saturation WRITE setSaturation NOTIFY saturationChanged)
    Q_PROPERTY(qreal clarity READ clarity WRITE setClarity NOTIFY clarityChanged)
    Q_PROPERTY(qreal sharpen READ sharpen WRITE setSharpen NOTIFY sharpenChanged)
    Q_PROPERTY(qreal highlights READ highlights WRITE setHighlights NOTIFY highlightsChanged)
    Q_PROPERTY(qreal shadows READ shadows WRITE setShadows NOTIFY shadowsChanged)

    Q_PROPERTY(QQuickItem* __originalImageOutput READ __originalImageOutput NOTIFY __outputChanged)
    Q_PROPERTY(QQuickItem* __output READ __output NOTIFY __outputChanged)
    Q_PROPERTY(QString loadedImagePath READ loadedImagePath NOTIFY loadedImagePathChanged)

public:
    explicit ImageProcessor(QObject *parent = 0);
    ~ImageProcessor();

    QQuickItem* filter() const { return m_filter; }

    QUrl filterUrl() const { return m_filterUrl; }
    void setFilterUrl(const QUrl &url);

    qreal filterOpacity() const { return m_filterOpacity; }
    void setFilterOpacity(const qreal &opacity);

    qreal vignetteOpacity() const { return m_vignetteOpacity; }
    void setVignetteOpacity(const qreal &opacity);

    qreal temperature() const { return m_temperature; }
    void setTemperature(const qreal &temperature);

    qreal brightness() const { return m_brightness; }
    void setBrightness(const qreal &brightness);

    qreal contrast() const { return m_contrast; }
    void setContrast(const qreal &contrast);

    qreal hAxisAdjust() const { return m_hAxisAdjust; }
    void setHAxisAdjust(const qreal &adjust);

    qreal saturation() const { return m_saturation; }
    void setSaturation(const qreal &saturation);

    qreal clarity() const { return m_clarity; }
    void setClarity(const qreal &clarity);

    qreal sharpen() const { return m_sharpen; }
    void setSharpen(const qreal &sharpen);

    qreal highlights() const { return m_highlights; }
    void setHighlights(const qreal &highlights);

    qreal shadows() const { return m_shadows; }
    void setShadows(const qreal &shadows);

    QString loadedImagePath() const;

    void classBegin() override;
    void componentComplete() override;

    QQuickItem* __output() const;
    QQuickItem* __originalImageOutput() const;

    Q_INVOKABLE bool saveToDisk(const QString &destPath, int quality, int size = 2048);

    Q_INVOKABLE void loadImage(const QString &imagePath);

    Q_INVOKABLE bool setProperty(const QString &property, const QVariant &value);
    Q_INVOKABLE QVariant getProperty(const QString &property);

private:
    QUrl m_filterUrl;
    qreal m_filterOpacity;
    qreal m_vignetteOpacity;
    qreal m_temperature;
    qreal m_brightness;
    qreal m_contrast;
    qreal m_hAxisAdjust;
    qreal m_saturation;
    qreal m_clarity;
    qreal m_sharpen;
    qreal m_highlights;
    qreal m_shadows;

    OffscreenRenderer* m_offscreenRenderer;
    QQuickItem* m_imageContainer;
    QQuickItem* m_filter;

    QTimer* m_timer;

    QSharedPointer<QQuickItemGrabResult> m_grabber;
    QString m_destPath;
    int m_quality;

signals:
    void filterChanged();
    void filterUrlChanged();
    void filterOpacityChanged();
    void vignetteOpacityChanged();
    void temperatureChanged();
    void brightnessChanged();
    void contrastChanged();
    void hAxisAdjustChanged();
    void saturationChanged();
    void clarityChanged();
    void sharpenChanged();
    void highlightsChanged();
    void shadowsChanged();

    void __outputChanged();
    void loadedImagePathChanged();
    void imageSettingsChanged();
    void imageSaved(const QString &path);

public slots:
    void init();

private slots:
    void startQmlParametersTimer();
    void updateQmlParameters();

    void grabConnect();

};

#endif // IMAGEPROCESSOR_H
