#include "audioprovider.hpp"

#include "audiocollector.hpp"
#include "service.hpp"
#include <QMetaObject>
#include <qdebug.h>
#include <qthread.h>

namespace hornero::services {

AudioProcessor::AudioProcessor(QObject* parent)
    : QObject(parent) {}

AudioProcessor::~AudioProcessor() {
    stop();
}

void AudioProcessor::init() {
    m_timer = new QTimer(this);
    m_timer->setInterval(static_cast<int>(ac::CHUNK_SIZE * 1000.0 / ac::SAMPLE_RATE));
    connect(m_timer, &QTimer::timeout, this, &AudioProcessor::process);
}

void AudioProcessor::start() {
    // NOTE: Qt < 6.5 has no invokeMethod overload for member pointers with
    // arguments, so route through an argument-free lambda (same semantics).
    auto* collector = &AudioCollector::instance();
    QMetaObject::invokeMethod(collector, [collector, this]() { collector->ref(this); }, Qt::QueuedConnection);
    if (m_timer) {
        m_timer->start();
    }
}

void AudioProcessor::stop() {
    if (m_timer) {
        m_timer->stop();
    }
    auto* collector = &AudioCollector::instance();
    QMetaObject::invokeMethod(collector, [collector, this]() { collector->unref(this); }, Qt::QueuedConnection);
}

AudioProvider::AudioProvider(QObject* parent)
    : Service(parent)
    , m_processor(nullptr)
    , m_thread(nullptr) {}

AudioProvider::~AudioProvider() {
    if (m_thread) {
        m_thread->quit();
        m_thread->wait();
    }
}

void AudioProvider::init() {
    if (!m_processor) {
        qWarning() << "AudioProvider::init: attempted to init with no processor set";
        return;
    }

    m_thread = new QThread(this);
    m_processor->moveToThread(m_thread);

    connect(m_thread, &QThread::started, m_processor, &AudioProcessor::init);
    connect(m_thread, &QThread::finished, m_processor, &AudioProcessor::deleteLater);
    connect(m_thread, &QThread::finished, m_thread, &QThread::deleteLater);

    m_thread->start();
}

void AudioProvider::start() {
    if (m_processor) {
        AudioCollector::instance(); // Create instance on main thread
        QMetaObject::invokeMethod(m_processor, &AudioProcessor::start);
    }
}

void AudioProvider::stop() {
    if (m_processor) {
        QMetaObject::invokeMethod(m_processor, &AudioProcessor::stop);
    }
}

} // namespace hornero::services
