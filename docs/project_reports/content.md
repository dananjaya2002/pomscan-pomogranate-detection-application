proposal report 
Chapter 01 - Problem Statement  
Fruit quality assessment is a critical process in agriculture, in developing countries like Sri 
Lanka determining fruit ripeness and detecting early signs of disease primarily rely on 
manual inspection methods, which are time consuming and prone to human error. Farmers, 
particularly those in rural regions with limited access to advanced technologies often 
experience significant losses due to improper harvesting times, poor storage decisions or 
undetected diseases that spread rapidly within crops. 
 
Although recent advancements in computer vision and machine learning have 
demonstrated great potential in automating agricultural monitoring, most existing systems 
depend on cloud based processing or high-end hardware, both of which are often 
unaffordable and impractical for small scale farmers. Limited internet connectivity and the 
high computational requirements of these systems make them unsuitable for deployment 
of standard mobile devices commonly used in rural farming communities. 
 
Moreover, for crops such as pomegranate which is gaining popularity in Sri Lanka through 
newly introduced local varieties like Lanka Red and Malee Pink there is a lack of localized 
datasets and automated tools capable of accurately identifying ripeness stages and 
detecting diseases specific to these cultivars. This absence of region-specific data further 
reduces the accuracy of machine learning models. 
 
Therefore, there is an urgent need for a lightweight, real time solution that enables farmers 
to assess fruit quality effectively without relying on constant internet connectivity or 
expensive infrastructure. The proposed system aims to address these challenges by 
developing a mobile application integrated with optimized machine learning models. 
Additionally, by incorporating an augmented reality (AR) interface the system will provide 
interactive visual feedback on ripeness and disease status directly on the live camera feed, 
enabling farmers to gain deeper insights into their fields and make more informed decisions. 
 
 
 
 
 
 
 
 
 
 
 
 
 
Chapter 02 - Project description  
 
2.1 Background and Rationale  
Agriculture plays a critical role in Sri Lanka’s economy with fruit cultivation contributing 
substantially to both local food production and export value. Among these crops 
pomegranate (Punica granatum) has emerged as a high value fruit due to its nutritional 
benefits and market demand. However, determining the correct harvest time and detecting 
early stage diseases remain as challenges for farmers. Even though manual inspection is 
traditional they are inefficient and prone to error particularly under diverse environmental 
conditions. 
 
2.2 Project Overview  
This project aims to design and implement a real-time pomegranate fruit ripeness and 
disease detection system using lightweight on device ML models integrated into a Flutter 
based mobile application. The system is designed to be efficient, accessible and user friendly 
and specifically adaptable to low resource agricultural environments. 
 
Lightweight detection architectures such as YOLOv8 and EfficientDet will be used to localize 
pomegranate fruits from live camera input while MobileNet or EfficientNet classifiers will 
assess ripeness stages (unripe, semi ripe, and ripe) and identify visible disease symptoms. 
These models will be optimized for TensorFlow Lite (TFLite) allowing low latency and offline 
inference suitable for mid range Android smartphones. 
 
Existing studies including YOLO-Granada by Zhao et al. (2024) and YOLO-MSNet by Xu et al. 
(2025), have proven the capability of lightweight YOLO models for pomegranate detection 
and disease classification. Similarly, Al Ansari (2024) developed an AlexNet-based Android 
application for identifying pomegranate leaf diseases directly from mobile captured images, 
demonstrating the practicality of mobile based agricultural AI systems. However, these 
studies have primarily used datasets and environmental conditions from other regions 
limiting their adaptability to Sri Lankan varieties such as Lanka Red and Malee Pink. 
 
 
2.3 Dataset Development  
A distinguishable component of this project is the creation of a custom dataset focusing on 
Sri Lankan pomegranate varieties. These varieties differ from globally studied cultivars in 
color, texture and shape, which necessitates localized data for accurate detection. Images 
will be captured under various lighting, weather and background conditions to ensure 
model robustness and adaptability to real world field environments. 
 
 
 
 
To enhance dataset diversity image augmentation techniques including rotation, scaling, 
brightness adjustment, flipping will be applied. Additionally, publicly available datasets from 
Kaggle will be used to complement the dataset. This hybrid approach helps the model 
generalize better across varying fruit appearances while maintaining high accuracy in Sri 
Lankan conditions. 
 
2.4 Scope of the Project  
Included 
• On-device ML models for fruit detection, ripeness classification, and disease 
identification. 
• Dataset development, augmentation, and preprocessing. 
• Flutter mobile app with real-time camera inference. 
• TensorFlow Lite optimization and performance benchmarking. 
• AR-based visualization overlays on live camera feed. 
 
Excluded 
• Cloud-based inference or server side processing. 
• Disease detection beyond visually observable symptoms. 
 
2.5 Expected Outcomes 
• A fully functional mobile application with offline inference capability 
• Optimized ML models suitable for on device deployment 
• Custom dataset representing Sri Lankan pomegranate varieties 
• AR enhanced visual feedback for ripeness and disease information 
• Benchmark analysis for accuracy, frame rates and latency on mid-range Android 
devices 
 
2.6 Advantages and Practical Impact  
Unlike conventional cloud based agricultural applications, the proposed solution performs 
all computations entirely on device ensuring offline operation even in areas with poor or no 
internet connectivity. The system’s lightweight architecture and use of TensorFlow Lite 
optimization minimize latency while maintaining high inference accuracy. 
 
By supporting efficient real time decision making, the proposed system contributes to 
reducing harvest losses, improving fruit quality assessment and promoting data driven 
farming practices. Ultimately, it aligns with Sri Lanka’s vision of smart and sustainable 
agriculture. 
 
 
 
 
 
 
 
2.7 Project Objectives  
The primary objectives of this project are: 
• To develop and optimize lightweight ML models for detecting pomegranate fruits, 
classifying ripeness, and identifying disease conditions. 
• To integrate these models into a Flutter based mobile application with on device 
inference using TensorFlow Lite. 
• To design an AR based visualization interface that overlays ripeness and disease 
information on the live camera feed. 
• To evaluate model performance based on detection accuracy, latency and real time 
frame rates on mid-range Android devices. 
• To deliver an affordable, offline capable mobile solution that enhances productivity, 
reduces waste and supports Sri Lankan farmers in low resource agricultural 
environments. 
 
2.8 Project Keywords  
• Mobile Machine Learning 
• On-Device AI 
• Precision Agriculture 
• Object Detection 
• Augmented Reality 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
Chapter 03 - Research gap  
Despite rapid advancements in agricultural automation and fruit detection technologies, the 
domain of pomegranate ripeness and disease detection particularly in mobile based, low-
resource contexts remains underexplored. While several studies have achieved high 
accuracy using deep learning and computer vision techniques most of these solutions are 
optimized for laboratory environments or rely on cloud based processing, making them 
impractical for small scale farmers in developing countries like Sri Lanka. Furthermore, 
existing systems rarely consider the variability in regional cultivars, environmental 
conditions, and resource limitations of mobile hardware. This chapter identifies the key 
research gaps in current literature and technologies, realizing the need for a localized, 
lightweight and offline mobile solution that integrates real time detection with user friendly 
visualization through augmented reality (AR). 
 
 
3.1 Knowledge Gap  
Although several studies have explored pomegranate detection and disease identification 
using computer vision and machine learning, most research focuses on global or generalized 
datasets. Existing models lack adaptation to regional fruit varieties such as Lanka Red and 
Malee Pink, which are unique to Sri Lanka. There is a lack of comprehensive studies 
addressing fruit ripeness and disease detection specifically for these local cultivars under Sri 
Lankan environmental and lighting conditions. 
 
3.2 Technology Gap  
Xu et al. (2025) introduced YOLO-MSNet (YOLOv11n), a pruned YOLO model optimized for 
pomegranate detection, achieving notable accuracy improvements and reduced model size 
for efficient deployment. Similarly, Zhao et al. (2024) developed the YOLO-Granada project, 
which implemented a lightweight YOLOv5/ShuffleNet model for Android to classify 
pomegranate growth stages and detect disease symptoms in real time. However, these 
systems still rely on datasets and environmental conditions from other regions, and their 
architectures, though efficient, have not been fine-tuned or validated for low-resource 
mobile environments typical of Sri Lankan farming communities. Moreover, most of these 
studies focus on detection accuracy rather than the user experience or integration with 
augmented reality (AR) interfaces that could improve usability in field applications. 
 
3.3 Methodological Gap  
Existing models primarily depend on pre-trained datasets or synthetic augmentation, which 
may not represent real-world variations in fruit color, texture, or disease appearance found 
in Sri Lanka. The absence of region-specific datasets limits the generalization ability of these 
models when deployed in local contexts. 
 
 
 
 
3.4 Contextual Gap  
No current research has developed or deployed a lightweight, on-device machine learning 
system tailored for Sri Lankan pomegranate varieties that can operate efficiently offline and 
provide interactive feedback to farmers. 
 
To resolve these gaps this project proposes to create a localized dataset of Sri Lankan 
pomegranate images covering multiple ripeness stages and disease conditions to fine tune 
existing lightweight models such as YOLOv8 and MobileNet. The project will further 
integrate an augmented reality (AR) interface within a mobile application to deliver real 
time ripeness and disease visualization directly on the device ensuring accessibility for 
farmers with limited connectivity and resources. 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
Chapter 04 - Requirement Analysis   
These requirements ensure that the proposed system remains both technically efficient and 
contextually relevant. By combining lightweight machine learning models with an intuitive 
AR based interface, the application directly addresses the identified research gaps in 
accessibility and localization. Its offline mobile application based design allows real time 
fruit detection and classification even in low resource agricultural environments supporting 
Sri Lankan farmers with a practical and scalable technological solution. 
 
Here is the table regarding the Functional, non-functional and user requirements: 
 
Type Description 
Functional The system shall capture images using mobile cameras and detect 
pomegranate fruits in real time. 
Functional The system shall classify each detected fruit into ripeness categories and 
identify any diseased fruits using an augmented reality AR overlay 
Functional The system should provide more information about whether pomegranate 
fruit is diseased. 
Non-
Functional 
The system should operate offline with minimal latency 
Non-
Functional 
The application must run smoothly on mid-range Android devices. 
Non-
Functional 
The system should have a simple, user friendly UI for users. 
User Users should be able to detect fruit into ripeness categories and identify 
any diseased fruits and gain insights into them. 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
Chapter 05 – Finance  
his project does not require any external financial allocation. All development and 
experimentation will be conducted using my personal laptop which provides sufficient 
computational resources for model training and testing. 
 
The dataset used for model fine tuning is retrieved from two sources: 
• A self created dataset containing images of locally grown Sri Lankan pomegranate 
varieties (Lanka Red, Malee Pink, etc.). 
• An existing open source dataset available on Kaggle under the “Fruits / 
Pomegranate” section for reference and augmentation. 
 
Since both the hardware and datasets are available at no cost and the required software 
tools such as TensorFlow, PyTorch and Flutter are open source no budget or financial 
expenditure is required for this project. 
 
 
Chapter 06 - External organizations  
The project will be carried out in collaboration with Ms. L. G. I. Samanmalee, Assistant 
Director of Agriculture, Department of Agriculture, who will provide insights into 
pomegranate cultivation and supply images of pomegranates for the dataset used to train 
the machine learning model. 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
Chapter 07 - Time Frame / Timeline  
The project will be carried out in alignment with the university semester schedule from 
November 2025 to October 2026. The Gantt chart below illustrates the planned project 
activities and timeline. 
 
  Figure: Project Gantt chart illustrating the timeline for pomegranate ripeness and disease 
detection system.  
 
 
 
 
 
 
 
 
 
 
 
 
References  
• Zhao, Jifei & Li, Yi & Guo, Dawei & Fan, Yuqian & Wu, Xiaoying & Wang, Xinfa & 
Almodfer, Rolla. (2024). YOLO-Granada: A Lightweight Attentioned Yolo 
forPomegranates Fruit Detection. 10.21203/rs.3.rs-4005773/v1. 
• Xu, Liang & Li, Bing & Fu, Xue & Lu, Zhe & Li, Zelong & Jiang, Bai & Jia, Siye. (2025). 
YOLO-MSNet: Real-Time Detection Algorithm for Pomegranate Fruit Improved by 
YOLOv11n. Agriculture. 15. 1028. 10.3390/agriculture15101028. 
• Kaggle, “Pomegranate Fruit Image Dataset,” Available: https://www.kaggle.com 
• Al Ansari, Dr. Mohammed Saleh. (2024). A Machine Learning Approach to 
Pomegranate Leaf Disease Identification. International Journal on Recent and 
Innovation Trends in Computing and Communication. 11. 
10.17762/ijritcc.v11i9.9597






PID report
Chapter 01 - Introduction 
1.1. Purpose and Scope 
The Pomegranate Ripeness and Disease Detection System project addresses one of critical 
challenge in Sri Lankan agriculture which is the need for accessible, offline fruit quality 
assessment technology for small scale farmers. This project aims to develop a lightweight, 
real-time mobile application integrated with optimized machine learning models to enable 
farmers to determine fruit ripeness and detect diseases without relying on expensive 
infrastructure or constant internet connectivity. 
1.2. Background and Context 
Agriculture forms the backbone of Sri Lanka's economy with fruit cultivation contributing 
significantly to both local food production and export value. Pomegranate (Punica 
granatum) has emerged as a high value fruit due to its nutritional benefits and growing 
market demand. However, the lack of accurate ripeness assessment and early disease 
detection tools forces farmers to rely on traditional manual inspection methods which are 
time consuming, labor intensive and prone to human error. 
Sri Lankan pomegranate varieties such as Lanka Red and Malee Pink have unique 
characteristics distinct from globally studied cultivars. Current agricultural automation 
solutions depend heavily on cloud based processing or high-end hardware making them 
unaffordable and impractical for rural farming communities where internet connectivity is 
limited and computational resources are constrained. 
1.3. Problem Statement 
Fruit quality assessment in Sri Lanka currently relies on manual inspection methods that are 
inefficient and error prone. Farmers, particularly those in rural regions with limited access to 
advanced technologies experience significant financial losses due to improper harvesting 
timing, poor storage decisions and undetected diseases that spread rapidly within crops. 
Additionally, there is a critical absence of localized datasets and automated tools specifically 
adapted to Sri Lankan pomegranate varieties further reducing the accuracy and applicability 
of existing machine learning models. 
 
 
 
1.4. Scope and Limitations 
Included: 
• On-device machine learning models for pomegranate fruit detection, ripeness 
classification and disease identification 
• Custom dataset addition for development featuring Sri Lankan pomegranate 
varieties (Lanka Red, Malee Pink etc.) 
• Dataset augmentation and preprocessing techniques 
• Flutter mobile application with real-time camera-based inference 
• TensorFlow Lite optimization and performance benchmarking 
 
 
• Augmented reality (AR) visualization overlays on live camera feed 
Excluded: 
• Cloud-based inference or server-side processing 
• Disease detection beyond visually observable symptoms 
• Enterprise level production deployment 
1.5. Expected Impact and Stakeholders 
Primary Stakeholders: 
• Small scale farmers in rural Sri Lanka seeking efficient fruit quality assessment 
solutions 
• Department of Agriculture officials collaborating on dataset development and 
validation 
• Agricultural cooperatives looking to modernize farming practices 
Expected Impact: 
• Reduction in harvest losses through improved ripeness assessment accuracy 
• Improved fruit quality control and market competitiveness 
• Enhanced farmer productivity through faster decision making 
• Demonstration of practical, low-cost AI application in agricultural contexts 
• Alignment with Sri Lanka's vision for smart and sustainable agriculture 
 
 
 
Chapter 02 - Business Case 
2.1. Business Need 
The current manual fruit inspection process in rural Sri Lankan agriculture creates multiple 
inefficiencies and cost implications: 
• Manual labor costs: Fruit quality assessment requires significant manual labor time 
per harvest, diverting resources from other farming activities 
• Quality inconsistency: Human error in ripeness assessment leads to premature or 
delayed harvesting directly impacting fruit quality and market value 
• Disease spread: Delayed disease detection allows diseases to spread rapidly within 
crops increasing yield losses 
• Accessibility gap: Existing technological solutions require high computational 
resources, cloud connectivity and technical expertise that are unavailable to most 
small-scale farmers 
• Economic impact: Loss due to improper harvesting and undetected diseases directly 
affects farmer income and agricultural sector productivity 
 
 
2.2. Business Objectives 
This project establishes measurable objectives aligned with agricultural modernization 
goals: 
• Develop an offline capable mobile application enabling farmers to assess fruit 
ripeness and disease status in real-time without internet dependency 
• Achieve ≥95% accuracy on pomegranate detection and ripeness classification for Sri 
Lankan varieties under field conditions 
• Optimize machine learning models to run efficiently on mid-range Android devices 
with latency <500ms per inference 
• Create a reusable and localized dataset of 1000+ annotated pomegranate images 
representing multiple ripeness stages and disease conditions 
• Deliver an affordable solution zero direct cost to farmers that demonstrably reduces 
fruit assessment time and improves decision making quality 
• Establish a foundation for future agricultural AI applications in Sri Lanka through 
open-source dataset and model contributions 
 
 
Chapter 03 - Project Objectives 
This project focuses on delivering specific technical and practical outcomes: 
3.1. Functional Deliverables 
• Develop and optimize lightweight machine learning models (YOLOv8, 
MobileNet/EfficientNet) for detecting pomegranate fruits, classifying ripeness stages 
(unripe, semi-ripe, ripe), and identifying disease symptoms 
• Integrate trained models into a Flutter based mobile application with on-device 
inference using TensorFlow Lite. 
• Implement augmented reality (AR) visualization interface overlaying ripeness and 
disease information directly on the live camera feed 
• Create a custom dataset of 500–1000 annotated images of Sri Lankan pomegranate 
varieties captured under varied lighting, weather and field conditions 
3.2. Quality Criteria and Success Metrics 
• Detection accuracy: Grater than 95% precision and recall for pomegranate fruit 
detection on validation dataset 
• Classification accuracy: Grater than 90% accuracy for ripeness stage classification 
• Inference performance: Real-time performance (≥20 FPS) on mid-range Android 
devices 
• Latency: Average inference latency <500ms per frame on target devices 
 
 
• Offline functionality: Complete operation without cloud connectivity or internet 
requirements 
• User experience: Intuitive AR interface requiring minimal training for field users 
3.3. Acceptance Criteria 
• Application successfully runs on Android 10+ devices with 4GB+ RAM 
• Model files optimized to <100MB combined size for practical on-device deployment 
• AR overlays display accurately aligned with detected fruits and provide actionable 
information 
• Custom dataset includes diverse lighting conditions, growth stages, and disease 
variations 
• Acceptable performance benchmarks and studies documentation 
 
Chapter 04 - Literature Review 
4.1. Introduction and Search Strategy 
This project builds upon significant recent advances in lightweight object detection, mobile 
machine learning, and agricultural automation. A systematic review of current literature 
was conducted using academic databases (Scopus, IEEE Xplore) and repositories (arXiv, 
Kaggle), focusing on keywords including "pomegranate detection," "lightweight YOLO," 
"mobile machine learning," "agricultural computer vision," and "TensorFlow Lite 
deployment." 
4.2. Current Publications 
Recent publications demonstrate the viability of lightweight deep learning architectures for 
agricultural applications: 
- Pomegranate-Specific Research: Zhao et al. (2024) introduced YOLO-Granada, a 
lightweight YOLOv5/ShuffleNet model optimized for Android deployment that 
classifies pomegranate growth stages and detects disease symptoms in real-time. Xu 
et al. (2025) developed YOLO-MSNet, a pruned YOLOv11n model achieving notable 
accuracy improvements while maintaining reduced model size for efficient mobile 
deployment. Al Ansari (2024) demonstrated practical applicability by developing an 
AlexNet-based Android application for pomegranate leaf disease identification 
directly from mobile captured images. 
- Lightweight Model Architectures: MobileNet and EfficientNet series have become 
standard baselines for mobile-constrained environments, offering favorable 
accuracy-efficiency trade-offs. YOLOv8 and recent YOLO variants provide state-of-
the-art object detection with acceptable computational footprints for mobile 
deployment. 
 
 
- Mobile Machine Learning: TensorFlow Lite has emerged as the standard framework 
for on-device inference, enabling low-latency, offline-capable applications. 
Quantization and pruning techniques can reduce model sizes by 75–90% with 
minimal accuracy loss. 
4.3. Critical Analysis and Identified Gaps 
While these studies confirm the technical feasibility of mobile-based pomegranate 
detection significant gaps remain: 
1. Regional Adaptation Gap: Existing studies predominantly use datasets from other 
regions and do not account for the unique visual characteristics of Sri Lankan 
pomegranate varieties (Lanka Red, Malee Pink). These varieties differ substantially in 
color, texture, and shape from globally available datasets, limiting model 
generalization to local contexts. 
2. Dataset Localization Gap: Most research relies on pre-trained models or synthetic 
augmentation without developing comprehensive region-specific datasets. This 
limits performance and reliability when deployed in Sri Lankan agricultural 
environments with distinct lighting conditions, soil types, and pest profiles. 
3. User Experience Gap: Current systems emphasize detection accuracy but provide 
minimal consideration of practical farmer usability. Few implementations integrate 
intuitive AR interfaces or user-centered design principles for non-technical 
agricultural users. 
4. Deployment Validation Gap: Limited real-world field testing and performance 
benchmarking exist for low-resource environments typical of Sri Lankan farming 
communities. Most evaluations occur in controlled laboratory settings. 
5. Methodological Gap: Existing models depend on image augmentation and general-
purpose datasets rather than diverse natural field captures representing genuine 
variability in ripeness stages and disease manifestations. 
4.4. Implications for Project Design 
This project directly addresses identified gaps through: 
• Development of a localized dataset featuring Sri Lankan pomegranate varieties 
under authentic field conditions 
• Implementation of region-specific model fine-tuning using transfer learning from 
pre-trained architectures 
• Integration of user-friendly AR visualization for practical farmer accessibility 
• Field based performance evaluation and validation in real agricultural environments 
• Documentation of practical deployment considerations and latency benchmarks on 
target mid-range devices 
 
 
 
 
Chapter 05 - Method of Approach 
5.1. Research Design 
This project employs a prototyping and experimental research design, combining dataset 
creation, model development, and application implementation with iterative validation and 
performance evaluation. 
5.2. Data Collection and Preparation 
Dataset Scope: 
• Primary: 500–800 images of Sri Lankan pomegranate varieties (Lanka Red, Malee 
Pink) captured under diverse field conditions 
• Secondary: Complementary images from public Kaggle datasets for augmentation 
and generalization 
• Total target: 2000+ annotated images post-augmentation 
Collection Methodology: 
• Image captured under varied lighting conditions (morning, midday, evening sunlight) 
• Multiple weather conditions (clear, cloudy etc.) 
• Diverse backgrounds (sky, trees, ground) representing authentic field scenarios 
• Manual labeling of ripeness categories (unripe, semi-ripe, ripe) and disease type 
• Compliance with image consent and data privacy protocols in collaboration with the 
Department of Agriculture 
Preprocessing Pipeline: 
• Fruit detection to isolate pomegranate regions 
• Image normalization and alignment for consistent model input 
• Data augmentation techniques: rotation, scaling, brightness adjustments, horizontal 
flipping 
• Train/validation/test split: 70% / 20% / 10% 
5.3. Algorithms, Tools, and Frameworks 
Object Detection: 
- YOLOv8 for real-time fruit localization and bounding box generation 
Classification: 
- MobileNetV2 or EfficientNet for ripeness classification and disease identification 
- Transfer learning with fine-tuning on custom Sri Lankan dataset 
Model Optimization: 
- TensorFlow Lite (TFLite) conversion to reduce model size and inference latency 
- TensorFlow Model Optimization Toolkit for pruning and quantization 
- ONNX export for framework flexibility 
 
 
Mobile Development: 
- Flutter framework for cross-platform mobile application 
- TensorFlow Lite Flutter plugin for on-device inference 
- ARCore for augmented reality visualization 
Development Stack: 
- Python with TensorFlow, PyTorch, OpenCV 
- Jupyter Notebook for model experimentation and analysis 
- VS Code with Dart/Flutter extensions for mobile development 
- Git for version control and GitHub for repository management 
5.4. Evaluation Metrics and Validation Strategy 
Model Evaluation: 
• Precision, Recall, F1-Score for fruit detection 
• Accuracy, Confusion Matrix for ripeness classification 
Field Validation: 
• Real world performance testing on mid-range Android devices 
• Frame rate (FPS) measurement during live camera inference 
• User acceptance testing with sample farmers or agricultural extension officers 
 
 
Performance Benchmarking: 
• Model size analysis 
• Memory consumption on target devices 
• Battery impact assessment 
• Robustness testing under various environmental conditions 
5.5. Project Management Methodology 
This project will adopt Agile development practices: 
- Phase 1 (Nov–Dec 2025): Dataset creation, annotation, and augmentation 
- Phase 2 (Jan–Feb 2026): Model development, training, and fine-tuning 
- Phase 3 (Mar–Apr 2026): Model optimization (TFLite conversion) 
- Phase 4 (May–Jun 2026): Flutter application development and integration 
- Phase 5 (Jul–Aug 2026): Field testing, validation, and refinement 
- Phase 6 (Sep–Oct 2026): Documentation, benchmarking, and project completion 
 
 
 
 
 
 
Chapter 06 - Conceptual Diagram 
 Figure: High level Architecture Diagram. 
 
 
 
Chapter 07 - Initial Project Plan 
 Figure: Project Gantt chart illustrating the timeline for pomegranate ripeness and disease 
detection system.  
 
 
 
 
 
 
Chapter 08 Risk Analysis 
Risk 1: Dataset Quality and Quantity Challenges 
Description: Insufficient collection of diverse pomegranate images or poor annotation 
quality may limit model generalization to real-world field conditions. 
Likelihood: Medium | Impact: High 
Mitigation Strategies: 
• Establish clear annotation guidelines and conduct inter-rater reliability checks 
• Collaborate with Department of Agriculture to access diverse cultivar samples 
• Implement data augmentation techniques to artificially increase dataset diversity 
• Set minimum quality standards (image resolution ≤ 720p, clear fruit visibility) 
• Early pilot testing with 100 images to validate annotation process before scaling 
Risk 2: Model Accuracy Under Field Conditions 
Description: Trained models may not generalize well to uncontrolled field lighting, occlusion 
and environmental variability despite training on augmented data. 
Likelihood: Medium | Impact: High 
Mitigation Strategies: 
• Incorporate images captured under diverse natural lighting conditions during dataset 
collection 
• Implement ensemble learning combining YOLOv8 and alternative detection 
architectures 
• Conduct extensive field testing with real agricultural scenarios 
• Establish fallback mechanisms (e.g., user confirmation for borderline classifications) 
• Plan for model retraining with field feedback data if accuracy drops below thresholds 
Risk 3: Mobile Device Performance Constraints 
Description: Optimized models may exceed latency/memory targets on mid-range Android 
devices, compromising real-time performance. 
Likelihood: Medium | Impact: High 
Mitigation Strategies: 
• Early latency profiling on target hardware during development phases 
• Aggressive model quantization and pruning strategies 
• Implementation of frame skipping or reduced resolution processing if needed 
• Consider dual-model approach (fast detection + slower classification) 
• Maintain performance benchmarking dashboard throughout development 
 
 
 
 
Risk 4: Hardware and Infrastructure Failures 
Description: Loss of training data, corruption of trained models or development 
environment crashes may disrupt progress. 
Likelihood: Low | Impact: Medium 
Mitigation Strategies: 
• Implement daily automated backups to cloud storage (Google Drive, GitHub) 
• Maintain version control with regular commits and tagged releases 
• Document all training configurations and hyperparameters for reproducibility 
• Use cloud-based Jupyter notebooks (Google Colab) with GPU access as backup 
training environment 
• Maintain redundant copies of datasets across multiple storage locations 
References 
 
• Zhao, Jifei & Li, Yi & Guo, Dawei & Fan, Yuqian & Wu, Xiaoying & W ang, Xinfa 
& Almodfer, Rolla. (2024). YOLO-Granada: A Lightweight Attentioned Yolo 
forPomegranates Fruit Detection. 10.21203/rs.3.rs-4005773/v1. 
• Xu, Liang & Li, Bing & Fu, Xue & Lu, Zhe & Li, Zelong & Jiang, Bai & Jia, Siye. (2025). 
YOLO-MSNet: Real-Time Detection Algorithm for Pomegranate Fruit Improved by 
YOLOv11n. Agriculture. 15. 1028. 10.3390/agriculture15101028. 
• Kaggle, “Pomegranate Fruit Image Dataset,” Available: https://www.kaggle.com 
• Al Ansari, Dr. Mohammed Saleh. (2024). A Machine Learning Approach to 
Pomegranate Leaf Disease Identification. International Journal on Recent and 
Innovation Trends in Computing and Communication. 11. 
10.17762/ijritcc.v11i9.9597.